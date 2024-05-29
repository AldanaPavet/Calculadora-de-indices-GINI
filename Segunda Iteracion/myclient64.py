from msl.loadlib import Client64

class MyClient64(Client64):
    """Call a function in 'libftoi' via the 'server32' wrapper."""

    def __init__(self):
        # Specify the name of the Python module to execute on the 32-bit server (i.e., 'my_server')
        super(MyClient64, self).__init__(module32='myserver32')

    def ftoi64(self, f):
        # The Client64 class has a 'request32' method to send a request to the 32-bit server
        # Send the 'f' argument to the 'add1' method in server32
        return self.request32('ftoi32', f)

    # def version(self):
    #     # Get the version
    #     return self.request32('version')