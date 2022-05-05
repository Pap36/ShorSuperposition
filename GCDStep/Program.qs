namespace GCDStep.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;    
    open Microsoft.Quantum.Logical;
    

    // given the quantum state |a>|b>|0>, the operation returns
    // the quantum state |b>|a mod b>|a // b> 
    operation GCDStep(aQ: Qubit[], bQ: Qubit[], auxDiv: Qubit[]): Unit is Adj + Ctl{
        
        DivideI(LittleEndian(aQ), LittleEndian(bQ), LittleEndian(auxDiv));
        // swap remainder and b between eachother
        for index in 0..Length(aQ) - 1{
            SWAP(aQ[index], bQ[index]);
        }
    }

    
    // operation used to numerically check the validity of the implementation
    // given a and b the operation performs the iterative from Euclid's algorithm
    // gcdStep(a, b) = (b, a % b)
    operation testGCDStep(a: BigInt, b: BigInt) : Int[] {
        
        let aB = BigIntAsBoolArray(a);
        let bB = BigIntAsBoolArray(b);
        

        // NOTE
        // If tested on a Quantum Simulator, make sure that the maximum value of size allowed
        // is 8. Alternatively, one can implement the mutable size code from the other 
        // operations to remove significant 0's in aB and bB and reduce the value of size to
        // what it really is

        // initialise the registers in state |a>|b>
        let size = Max([Length(aB), Length(bB)]);
        use aQ = Qubit[size];
        
        for index in 0..Length(aB) - 1 {
            if(aB[index] == true) {
                X(aQ[index]);
            }
        }

        use bQ = Qubit[size];
        
        for index in 0..Length(bB) - 1 {
            if(bB[index] == true) {
                X(bQ[index]);
            }
        }

        // prepare register in state |0> to store the result
        use auxDiv = Qubit[size];

        GCDStep(aQ, bQ, auxDiv);
        // use auxiliary registers to store the results
        use auxA = Qubit[size];
        use auxB = Qubit[size];

        AddI(LittleEndian(aQ), LittleEndian(auxA));
        AddI(LittleEndian(bQ), LittleEndian(auxB));

        let aRes = MeasureInteger(LittleEndian(auxA));
        let bRes = MeasureInteger(LittleEndian(auxB));
        // reverse the operation so that auxDiv is back to 0
        Adjoint GCDStep(aQ, bQ, auxDiv);

        for index in 0..Length(aB) - 1 {
            if(aB[index] == true) {
                X(aQ[index]);
            }
        }

        for index in 0..Length(bB) - 1 {
            if(bB[index] == true) {
                X(bQ[index]);
            }
        }

        return [aRes, bRes];

    }

    // operation used to set up a superposition of values using the Hadamard gat
    // so that the operation can be checked when running in superposition
    // also provides a good estimate for the number of qubits required when running
    // the resource estimator
    operation testQubitCount(registerSize: Int): Unit {
        use aQ = Qubit[registerSize];
        use bQ = Qubit[registerSize];
        use cQ = Qubit[registerSize];

        ApplyToEachA(H, aQ);
        ApplyToEachA(H, bQ);

        GCDStep(aQ, bQ, cQ);
        Adjoint GCDStep(aQ, bQ, cQ);
    }

}
