"""
Embedded Python Blocks:

Each this file is saved, GRC will instantiate the first class it finds to get
ports and parameters of your block. The arguments to __init__  will be the
parameters. All of them are required to have default values!
"""
import time
import numpy as np
from gnuradio import gr

class blk (gr.sync_block):
    """
    Block to analyze the data on an already squared signal, comprised of 0's and 1's.
    """

    def __init__ (self
                , samp_rate = None):  # only default arguments here
        """
        Constructor.

        Args:
            samp_rate -> Rate (in samples per second) that the flowgraph is working with,
                to deduce the frequency of the detected signal.
        """
        gr.sync_block.__init__(
            self,
            name = 'OOK statistics sink',
            in_sig = [np.float32],
            out_sig = []
        )

        self.time_delta = 0 # Timer to measure the time between edges

        # Max and min bursts, to print statistics
        self.max_burst = 0
        self.min_burst = np.inf

        # Lists to store timestamps of rising and falling edges
        self.rising_timestamps = []
        self.falling_timestamps = []

        # Last sample of the previous frame to handle the edge case of one fram ending
        # with 0 and the following starting with 1 (thus, not detecting a rising edge)
        self.previous_sample = 0

        # Counter to determine the end of a packet. If more than (2 * threshold) samples
        # are set to 0, the packet is done
        self.allzero_count = 0

        # ---- Statistics ----
        self.acc_mean = 0
        self.acc_mean_counter = 0 # Counter to calculate the accumulative mean

        self.short_bursts = {}
        self.long_bursts = {}

        self.short_median = None
        self.long_median = None

        self.samp_rate = samp_rate


    def calc_median (self, bursts):
        """
        Calculates the median of the given histogram

        Args:
            bursts -> Dictionary with the counts of each burst length

        Returns:
            The median of the given histogram
        """
        median = 0
        acc = 0
        n = sum (bursts [k] for k in bursts) # Total number of samples
        stop = (n / 2.) # if n % 2 == 0 else (n + 1) / 2

        idx = 0
        keys = sorted (bursts)

        while acc < stop:
            k = keys [idx]
            acc += bursts [k]

            if acc > stop:
                median = k

            idx += 1

        # If it's an even number of elements, gets the average between the center values
        if (n % 2 == 0) and (idx > 0) and (idx < len (keys)):
            median = (keys [idx - 1] + keys [idx]) / 2

        return median


    def print_stats (self):
        """
        Prints the collected statistics
        """
        # Separator
        print ("*" * 30)

        # Prints min, max, and some other statistics
        print ("=> General stats: ")
        print ("\t -> Min burst: " + str (self.min_burst))
        print ("\t -> Max burst: " + str (self.max_burst))

        print ("\t -> Mean: " + str (self.acc_mean))

        # Long and short bursts
        print ("=> Short bursts: ")
        print ("\t -> Median: "
                + (str (self.short_median)
                    if self.short_median else
                    "-"
                )
        )
        print ("\t -> Longer burst: "
                + (str (sorted (self.short_bursts).pop ())
                    if len (self.short_bursts) > 0 else
                    "-"
                )
        )

        print ("=> Long bursts: ")
        print ("\t -> Median: "
                + (str (self.long_median)
                    if self.long_median else
                    "-"
                )
        )
        print ("\t -> Shorter burst: "
                + (str (sorted (self.long_bursts) [0])
                    if len (self.long_bursts) > 0 else
                    "-"
                )
        )

        # Period and frequency
        if self.samp_rate:

            period = ((self.short_median + self.long_median)
                        if (self.short_median and self.long_median) else
                        None
            )

            print ("=> Signal period (median): "
                    + (str (period) if period else "N.A.")
                    + " samples "
                    + "(" + (str (self.samp_rate / float (period)) if period else "N.A.")
                    + " Hz)"
            )




    def work (self, input_items, *args, **kwargs):
        """
        Counts the different times measured between edges

        Args:
            input_items -> Array with the items from the previous block

        Returns:
            The length of the processed input array
        """
        samples = input_items [0]
        diff = np.diff (samples)

        # Gets the indices of rising and falling edges
        falling = np.where (diff == -1)[0]
        rising = np.where (diff == 1)[0]

        # Takes care of an edge at the beginning
        if (self.previous_sample != samples [0]):
            if samples [0] == 0:
                # Falling edge
                falling = np.append (0, falling)
            else:
                # Raising edge
                rising = np.append (0, rising)

        self.previous_sample = samples [len (samples) - 1]

        # If the signal is flat, skips the rest of the processing
        if (len (rising) <= 0
            and
            len (falling) <= 0
        ):
            if samples [0] == 0:
                # All 0's
                self.allzero_count += len (samples)

                return len (samples)
            else:
                # All 1's
                self.allzero_count = 0
                self.time_delta += len (samples)
                return len (samples)
        else:
            # Prints the number of samples set to 0 (supposedly from the previous packet)
            if (self.allzero_count > 0):
                print ("-" * 20)

                print ("Samples set to 0 (distance between packets): "
                        + str (self.allzero_count)
                )


            self.allzero_count = 0

            self.rising_timestamps += [ (x + self.time_delta) for x in rising ]
            self.falling_timestamps += [ (x + self.time_delta) for x in falling ]

            # Process the edges when there's at least one burst (rising + falling edges)
            if (len (self.rising_timestamps) == len (self.falling_timestamps)
                and
                len (self.rising_timestamps) >= 1
                and
                len (self.falling_timestamps) >= 1
            ):

                for rise, fall in zip (self.rising_timestamps, self.falling_timestamps):
                    diff = fall - rise

                    if diff < self.min_burst:
                        self.min_burst = diff

                    if diff > self.max_burst:
                        self.max_burst = diff

                    # Iterative mean, using the algorithm from Heiko Hoffman's web page
                    # http://www.heikohoffmann.de/htmlthesis/node134.html
                    #
                    # This avoids the possible overflow of storing the sum to calculate
                    # it the usual way (new_mean = (mean + x) / N)
                    self.acc_mean_counter += 1

                    self.acc_mean = (self.acc_mean
                                + (1. / self.acc_mean_counter)
                                * (diff - self.acc_mean)
                    )

                    # Waits until significant data is available to classify the bursts
                    if self.acc_mean_counter > 10:

                        if diff < self.acc_mean:
                            # Shorter than the average
                            if diff in self.short_bursts:
                                self.short_bursts [diff] += 1
                            else:
                                self.short_bursts [diff] = 1

                            self.short_median = self.calc_median (self.short_bursts)
                        else:
                            # Longer than the average
                            if diff in self.long_bursts:
                                self.long_bursts [diff] += 1
                            else:
                                self.long_bursts [diff] = 1

                            self.long_median = self.calc_median (self.long_bursts)


                    # Removes the processed timestamps
                    self.rising_timestamps.remove (rise)
                    self.falling_timestamps.remove (fall)

                self.print_stats ()

                # If both lists are empty, the counter can be resetted
                if (len (self.rising_timestamps) == 0
                    and
                    len (self.falling_timestamps) == 0
                ):
                    self.time_delta = 0

            self.time_delta += len (samples)

        return len (samples)
