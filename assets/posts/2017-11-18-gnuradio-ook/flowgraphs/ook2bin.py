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
    Block to decode the data on an already squared signal, comprised of 0's and 1's.
    """

    def __init__ (self
                , baseband_freq = 600
                , sample_rate = 2e6
                , sink_file = None):  # only default arguments here
        """
        Constructor.

        Args:
            baseband_freq -> Frequency of the baseband signal

            sample_rate -> Number of samples per second

            sink_file -> File to dump the packets. If it's 'None', prints them on STDOUT
        """
        gr.sync_block.__init__(
            self,
            name = 'OOK to bin sink',
            in_sig = [np.float32],
            out_sig = []
        )

        # Number of samples to discern long and short bursts
        #   sample_rate / baseband_freq = samples_per_period
        self.threshold = (sample_rate / baseband_freq) / 2

        self.sink_file = sink_file

        self.time_delta = 0 # Timer to measure the time between edges

        # Lists to store timestamps of rising and falling edges
        self.rising_timestamps = []
        self.falling_timestamps = []

        # Last sample of the previous frame to handle the edge case of one fram ending
        # with 0 and the following starting with 1 (thus, not detecting a rising edge)
        self.previous_sample = 0

        # Counter to determine the end of a packet. If more than (2 * threshold) samples
        # are set to 0, the packet is done
        self.allzero_count = 0

        self.packet = [] # List to store the bits of the packet


    def dump_packet (self):
        """
        Dumps the packet captured on the output file (or STDOUT)
        """
        bin_str = str (time.time ()) + ": \t" + "".join (self.packet)

        if not self.sink_file:
            print (bin_str)
        else:
            print self.sink_file
            with open (self.sink_file, "a") as f:
                f.write (bin_str + "\n")

        self.packet = []


    def work (self, input_items, *args, **kwargs):
        """
        Processing done to retrieve the binary string from the squared signal.

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

                if (self.allzero_count > (2 * self.threshold)
                    and
                    len (self.packet) > 0
                ):
                    # End of a packet
                    self.dump_packet ()

                return len (samples)
            else:
                # All 1's
                self.allzero_count = 0
                self.time_delta += len (samples)
                return len (samples)
        else:
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

                    if diff < self.threshold:
                        # Short burst
                        self.packet.append ("0")
                    else:
                        # Long burst
                        self.packet.append ("1")

                    # Removes the processed timestamps
                    self.rising_timestamps.remove (rise)
                    self.falling_timestamps.remove (fall)

                # If both lists are empty, the counter can be resetted
                if (len (self.rising_timestamps) == 0
                    and
                    len (self.falling_timestamps) == 0
                ):
                    self.time_delta = 0

            self.time_delta += len (samples)

        return len (samples)
