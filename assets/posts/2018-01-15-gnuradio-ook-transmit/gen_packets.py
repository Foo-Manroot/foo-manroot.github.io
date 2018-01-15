"""
Embedded Python Blocks:

Each this file is saved, GRC will instantiate the first class it finds to get
ports and parameters of your block. The arguments to __init__  will be the
parameters. All of them are required to have default values!
"""
import re \
    , exrex

import numpy as np
from gnuradio import gr

class blk (gr.sync_block):
    """
    Generates all possible combinations of 'n' bits packets that match the given pattern
    """

    def __init__ (self
                , n = 2
                , repetitions = 1
                , pattern = ".*"
                , spacing = 3
                , comb_spacing = 30
    ):  # only default arguments here
        """
        Constructor

        Args:
            n -> Number of bits per packet

            repetitions -> Number of times that every matched combination should be
                repeated

            pattern -> Regex (accepted by 're') to filter the accepted bit strings

            spacing -> Number of periods left blank between packets

            comb_spacing -> Number of periods left blank between the last packet
                    of one combination and the first of the next combination.
        """
        gr.sync_block.__init__ (
            self,
            name = 'Packet source',
            in_sig = [],
            out_sig = [np.int8]
        )

        self.n = n
        self.repetitions = repetitions
        self.pattern = pattern
        self.spacing = spacing
        self.comb_spacing = comb_spacing

        self.remaining = []
        self.generator = self.gen_packet ()


    def gen_packet (self):
        """
        Infinite generator
        Generates all combinations of n_bits that matches the given pattern and repeats
        them again.

        Returns:
            A list with the generated combination
        """
        n = self.n
        spacing = self.spacing
        repetitions = self.repetitions
        pattern = self.pattern

        # Substitues '.' for '[01]', as packets are a binary string
        pattern = re.sub ("[.]", "[01]", pattern)
        # Python's regex substitutes '*' for {0, 4294967295}, and '+' for {1, 4294967295}.
        # To reduce the output of exrex, 4294967295 is changed for n
        pattern = re.sub ("[*]", "{0," + str (n) +  "}", pattern)
        pattern = re.sub ("[+]", "{1," + str (n) +  "}", pattern)


        if exrex.count (pattern, limit = n + 1) < (2 ** self.n):

            # Generated with exrex (reversing the regular expression)

            while True:
                for b in exrex.generate (pattern, limit = n + 1):

                    # Spacing between packets
                    yield [2] * self.comb_spacing

                    if len (b) == n:
                        # Repeats the current combination 'repetitions' times, if it matches
                        for i in xrange (repetitions):

                            yield [ int (x) for x in b ] + [2] * spacing
                            print b

        else:
            # Normal generation (pure bruteforcing)

            regex = re.compile (pattern)
            b = 0
            while True:

                s = "{0:b}".format (b).zfill (n)

                if regex.match (s):
                    # Spacing between packets
                    yield [2] * self.comb_spacing

                    # Repeats the current combination 'repetitions' times, if it matches
                    for i in xrange (repetitions):

                        yield [ int (x) for x in s ] + [2] * spacing
                        print s

                # Restarts the counter
                if b >= ((2 ** n) - 1):
                    b = 0
                else:
                    b += 1


    def work (self, input_items, output_items):
        """
        Signal processing
        """
        extra_pkt = []
        # Fills the buffer with the current packet
        room = (len (output_items [0]) - len (self.remaining))

        # To avoid exceptions when output_items is little, takes only the previous items
        if room <= 0:
            output_items [0][:] = np.array (self.remaining [:len (output_items [0])])
            self.remaining = self.remaining [len (output_items [0]):]

            return len (output_items [0])


        packet = []
        acc_len = 0

        while len (packet) < room:
            tmp = self.generator.next ()
            acc_len += len (tmp)
            packet += tmp


        output_items [0][:] = np.array (
                                self.remaining
                                + packet [:room]
        )

        # Stores the remaining bits to be sent on the next buffer
        if acc_len > room:
            self.remaining = packet [room:]
        else:
            self.remaining = []


        return len (output_items [0])
