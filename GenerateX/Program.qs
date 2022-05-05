namespace GenerateX.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;

    // given a number r and a target registerm the operation initialises the
    // quantum register so it is in state |r>
    // size is the bit-length of r
    operation storeR(r : Int, rQ : Qubit[], size: Int) : Unit is Adj + Ctl {
        let rB = IntAsBoolArray(r, size); 
        for index in 0..(Length(rB) - 1){
            if(rB[index]) {
                X(rQ[index]);
            }
        }
    }

    // operation used to numerically check the validity of the implementation
    // given N, r and the bit-length of r, the operation return s
    operation GenerateXVal(N : BigInt, r : Int, size: Int) : Int{
        // start by initialising a quantum register to be instate |N>
        let NB = BigIntAsBoolArray(N);
        mutable Nsize = 0;
        for index in 0..Length(NB) - 1{
            if(NB[index]){
                set Nsize = index + 1;
            }
        }

        // Message("The size values are Nsize and rSize " + IntAsString(Nsize) + " " + IntAsString(size));
        use NQ = Qubit[Max([Nsize, size])];
        for index in 0..Nsize {
            if(NB[index]) {
                X(NQ[index]);   
            }
        }
        // prepare a quantum register in state |0> in which the result |x> will be stored
        use x = Qubit[Length(NQ)];
        generateX(NQ, r, x, size);

        // create an auxiliary result register to check the numerical value
        use finalRes = Qubit[Length(NQ)];
        AddI(LittleEndian(x), LittleEndian(finalRes));
        let res = MeasureInteger(LittleEndian(finalRes));
        // reverse the operation to verify that the qubits are back in state |0>
        Adjoint generateX(NQ, r, x, size);
        for index in 0..Nsize {
            if(NB[index]) {
                X(NQ[index]);   
            }
        }

        return res;
    }

    // given the quantum state |N>|0> and the integer r, the operation returns
    // the quantum state |N>|x> where x = 1 + r mod (N - 1)
    operation generateX(N : Qubit[], r : Int, x : Qubit[], size: Int) : Unit is Adj + Ctl{
        // X = 1 + r mod (N-1)
        // first compute N - 1
        
        // Switch between IncrementByInteger and Adjoint AddI (one...) depending
        // on the choice of simulator that is being used
        // Toffoli uses AddI and one, whereas Quantum Sim uses IncrementByInteger
        Adjoint IncrementByInteger(1, LittleEndian(N));
        // use one = Qubit();
        // X(one);
        // Adjoint AddI(LittleEndian([one]), LittleEndian(N));
        
        // assign r to register
        use rQ = Qubit[Length(N)];
        storeR(r, rQ, size);
        // compute r mod N-1
        use res = Qubit[Length(N)];
        DivideI(LittleEndian(rQ), LittleEndian(N), LittleEndian(res));
        AddI(LittleEndian(rQ), LittleEndian(x));
        
        IncrementByInteger(1, LittleEndian(x));
        //AddI(LittleEndian([one]), LittleEndian(x));

        Adjoint DivideI(LittleEndian(rQ), LittleEndian(N), LittleEndian(res));
        Adjoint storeR(r, rQ, size);
        
        IncrementByInteger(1, LittleEndian(N));
        
        //AddI(LittleEndian([one]), LittleEndian(N));
        //X(one);
    }

    // operation used to set up a superposition of values using the Hadamard gat
    // so that the operation can be checked when running in superposition
    // also provides a good estimate for the number of qubits required when running
    // the resource estimator
    operation Testing_in_Superposition(Ran: Int, numQubits: Int, size: Int): Unit{
        use x = Qubit[numQubits];
        use n = Qubit[numQubits];
        //Putting m into superposition
        ApplyToEach(H,n);

        generateX(n, Ran, x, size);
        Adjoint generateX(n, Ran, x, size);

    }

    // INITIAL APPROACH TO IMPLEMENTING SUBTRACT BY 1 USING ONLY 1 AUXILIARY QUBIT

    // operation minusX(q : Qubit[], index : Int) : Unit is Adj + Ctl{
    //     body(...){

    //     }
    //     controlled(cond, ...){
    //         Controlled X(cond, q[index]);
    //         if(index < Length(q) - 1) {
    //             Controlled minusX(cond + [q[index]], (q, index + 1));
    //         }
    //     }
    //     adjoint auto;
    //     adjoint controlled (cond, ...){
    //         // I need to do this, but only if cond is all 1
    //         // However, before I do this, we need to make sure if the other also needs it
    //         if(index < Length(q) - 1){
    //             Controlled Adjoint minusX(cond + [q[index]], (q, index + 1));
    //         }
    //         Controlled X(cond, q[index]);
    //     }
    // }

    // operation minus1(q : Qubit[]) : Unit is Adj{
    //     body(...) {
    //         X(q[0]);
    //         Controlled minusX([q[0]], (q, 1));
    //     }
    //     adjoint(...) {
    //         // I need to do this, but I will only do the controlled on bits that are 0
    //         //X(q[0]);
    //         Controlled Adjoint minusX([q[0]], (q, 1));
    //         X(q[0]);
    //     }
    // }

    // operation add1(target: Qubit[]): Unit {
    //     mutable control = 1;
    //     for index in 0..Length(target) - 1{
    //         if(control == 1){
    //             X(target[index]);
    //             use temp = Qubit();
    //             Controlled X([target[index]], temp);
    //             set control = (MeasureInteger(LittleEndian([temp])) + 1) % 2;
    //         }
    //     }
    // }

    // operation subtract1(target: Qubit[]): Unit {
    //     mutable control = 1;
    //     for index in 0..Length(target) - 1{
    //         if(control == 1){
    //             X(target[index]);
    //             use temp = Qubit();
    //             Controlled X([target[index]], temp);
    //             set control = MeasureInteger(LittleEndian([temp]));
    //         }
    //     }
    // }

}
