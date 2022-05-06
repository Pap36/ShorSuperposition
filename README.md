# ShorSuperposition
 This repository represents the implementation of Shor's algorithm in superposition using Q# and the MQDK. The algorithm itself cannot be run on neither a quantum simulator, due to the large number of qubits required, not on a Toffoli Simulator, because of the inverse QFT operation which it required. However, it is possible to use the Resource Estimator part of the MQDK to find how many qubits it would require to factor a number N with n bits. Note that n is a parameter which can be modified in the code.

# Running the code
 First, make sure that a Q# development is installed and correctly set up. A good resource for this is https://docs.microsoft.com/en-us/azure/quantum/. It is recommended that the code is run either from the command
 line, or inside Visual Studio Code or any other IDE. However, it is possible to run some of the individual quantum operations in a Jupyter Notebook as well. This could be useful is one wants to use the magical trace command to get a visual representation of the quantum circuit.

# Notes
 The Toffoli Simulator cannot run any operations which use Hadamard Gates, phase rotations or phase shifts. Because of this, make sure that when using the Toffoli Simulator to run an individual operation which uses the IncrementByInteger quantum operation provided by the MQDK you comment it out and change it with the use one = Qubi() X(one) AddI(..) etc. Similarly, when estimating the resources required by such an operation, make sure that it uses the IncrementByInteger operation as it is the most efficient between the two approaches.