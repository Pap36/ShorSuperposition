namespace GCD.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;    
    open Microsoft.Quantum.Logical;
    open GCDStep.Testing;

    // operation used to numerically check the validity of the implementation
    // given a and b the operation return gcd(a, b)
    operation testGCD(a: BigInt, b: BigInt) : Int {
        
        // initialise the quantum registers in state |a>|b>
        let aB = BigIntAsBoolArray(a);
        let bB = BigIntAsBoolArray(b);

        let size = Max([Length(bB), Length(aB)]);

        use aQ = Qubit[size];
        for index in 0..Length(aB) - 1 {
            if(aB[index]) {
                X(aQ[index]);
            }
        }

        
        use bQ = Qubit[size];
        for index in 0..Length(bB) - 1 {
            if(bB[index]) {
                X(bQ[index]);
            }
        }

        // prepare quantum regoster in state |0> for the result
        use resQ = Qubit[size]; 
        GCD(aQ, bQ, resQ, false);
        // use auxiliary register to numerically verify the result
        use finalRes = Qubit[size];
        AddI(LittleEndian(resQ), LittleEndian(finalRes));
        
        // reverse the operation
        GCD(aQ, bQ, resQ, true);
        let result = MeasureInteger(LittleEndian(finalRes));
        
        for index in 0..Length(aB) - 1 {
            if(aB[index]) {
                X(aQ[index]);
            }
        }

        for index in 0..Length(bB) - 1 {
            if(bB[index]) {
                X(bQ[index]);
            }
        }

        return result;
    }

    // given the quantum state |a>|b>|0>, the operation returns
    // the quantum state |a>|b>|gcd(a, b)> 
    operation GCD(aQ: Qubit[], bQ: Qubit[], result: Qubit[], reversing: Bool): Unit {

        // prepare the values for the number of steps in the pebble game and
        // the required number of intermediate values to be stored according to
        // Bennet's conversion algorithm

        let target = Ceiling(IntAsDouble(Length(bQ)) * 1.44); 
        let value = Ceiling(Log(IntAsDouble(target)) / Log(2.0) + 2.0);

        let fixedBiggestSize = Max([Length(aQ), Length(bQ)]);

        // initialise the registers for the intermediate values
        use intermediateValuesAQ = Qubit[fixedBiggestSize * (value - 1)];
        use intermediateValuesBQ = Qubit[fixedBiggestSize * (value - 1)];
        use intermediateValuesAuD = Qubit[fixedBiggestSize * (value - 1)];
        
        // initialise the registers for the new values (output after every pebbling step)
        use newAQ = Qubit[fixedBiggestSize];
        use newBQ = Qubit[fixedBiggestSize];
        use newAuxDiv = Qubit[fixedBiggestSize];
        
        // make sure that the first value stored in the intermediates is the initial value
        for index in 0..Length(aQ) - 1{
            Controlled X([aQ[index]], intermediateValuesAQ[index]);
            Controlled X([bQ[index]], intermediateValuesBQ[index]);
        }

        // prepare classical array which keeps track of which slots are occupied
        mutable indexArr = [-1, size = target + 2];
        set indexArr w/= 0 <- 0;
        
        // control qubit to check if the result has been fount + qubit used in the 
        // AND gate
        use controlQ = Qubit();
        use areTheSame = Qubit();
        
        // start the pebbling algorithm
        set indexArr = pebbleStep(0, value - 1, target, indexArr, intermediateValuesAQ, 
                intermediateValuesBQ, intermediateValuesAuD, newAQ, newBQ, newAuxDiv,
                result, controlQ, areTheSame, fixedBiggestSize, reversing);


        X(controlQ); // because the result was hopefully found, controlQ should be 1

        // reset the original value stored in the intermediate array back to 0
        for index in 0..Length(aQ) - 1{
            Adjoint Controlled X([aQ[index]], intermediateValuesAQ[index]);
            Adjoint Controlled X([bQ[index]], intermediateValuesBQ[index]);
        }

    }

    // operation takes as input |a>|b>|0> and returns |a>|b>|a AND b>
    operation andGate(qubit1: Qubit, qubit2: Qubit, qubit3: Qubit): Unit is Adj + Ctl {
        Controlled X([qubit1], qubit3);
        Controlled X([qubit2], qubit3);
    }

    // operation takes as input the current values in the Euclidean algorithm
    // every new value quantum register is in state 0
    // the new value from the algorithm is computed if and only if the current
    // denominator (bQ) is not 0
    // operation arrows for reversability as well
    operation pebbleGCDStep(currAQ: Qubit[], currBQ: Qubit[], newAQ: Qubit[], newBQ: Qubit[],
        newAuxDiv: Qubit[], adj: Bool): Unit {
        
        if(not adj){
            AddI(LittleEndian(currAQ), LittleEndian(newAQ));
            AddI(LittleEndian(currBQ), LittleEndian(newBQ));
            let zeroDiv = computeValue(currBQ);
            
            // if b != 0, perform the GCD Step
            if(zeroDiv != 0){
                GCDStep(newAQ, newBQ, newAuxDiv);
            }
        } else {

            let zeroDiv = computeValue(currBQ);
        
            if(zeroDiv != 0){
                Adjoint GCDStep(newAQ, newBQ, newAuxDiv);
            }

            Adjoint AddI(LittleEndian(currAQ), LittleEndian(newAQ));
            Adjoint AddI(LittleEndian(currBQ), LittleEndian(newBQ));
        }
        
    }

    // classical operation which reflects the PebbleStep function described in the report in Algorithm 1
    // operation returns an array of integers representing the state of the indexes array
    operation pebbleStep(currentIndex: Int, maximumIndex: Int, targetIndex: Int, indexArr: Int[],
                            intermediateValuesAQ: Qubit[], intermediateValuesBQ: Qubit[], intermediateValuesAuD: Qubit[], 
                            newAQ: Qubit[], newBQ: Qubit[], newAuxDiv: Qubit[],
                            result: Qubit[], control: Qubit, areTheSame: Qubit, fixedBiggestSize: Int,
                            reversing: Bool): Int[] {
        
        mutable tempArr = indexArr; // the indexes array which we will modify and return
        
        // all steps are identical to the algorithm in the report
        if(maximumIndex != 0) {
            let nextIndex = currentIndex + PowI(2, maximumIndex - 1);
            set tempArr = pebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesAQ, 
                intermediateValuesBQ, intermediateValuesAuD, newAQ, newBQ, newAuxDiv,
                result, control, areTheSame, fixedBiggestSize, reversing);
            
            mutable startIndexInter = 0;
            
            if(tempArr[targetIndex] != -1 or nextIndex < targetIndex){

                // place a pebble
                pebbleGCDStep(intermediateValuesAQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)],
                             intermediateValuesBQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)],
                             newAQ, newBQ, newAuxDiv, false);

                // check if the result has been found
                let remVal = computeValue(newBQ);
                if(remVal == 0){
                    // use a temporary qubit to verify if we have already found the result or not
                    // prevents from adding the result to the target register more than once
                    use temp = Qubit();
                    Controlled X([control], temp);
                    X(control);
                    if(not reversing){
                        Controlled AddI([control], 
                        (LittleEndian(intermediateValuesBQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)]), 
                        LittleEndian(result)));
                    } else {
                        Controlled Adjoint AddI([control], 
                        (LittleEndian(intermediateValuesBQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)]), 
                        LittleEndian(result)));
                    }
                    let value = MeasureInteger(LittleEndian([temp]));
                    if(value == 1){
                        X(control);
                    }
                }
                
                // copy all curr value in intermediate values
                // first find the slot in which to copy
                mutable count = 0;
                mutable found = false;
                for index in 0..Length(tempArr) - 1{
                    let predicate = EqualI(_, (count + 1) * fixedBiggestSize);
                    if(IndexOf(predicate, tempArr) == -1 and (not found)){
                        set found = true;
                    } elif(not found){
                        set count = count + 1;
                    }
                }
                set startIndexInter = (count + 1) * fixedBiggestSize;
                
                // copy the values
                for index in 0..fixedBiggestSize - 1{
                    Controlled X(
                        [intermediateValuesAQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesAQ[index + startIndexInter]
                    );

                    Controlled X(
                        [intermediateValuesBQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesBQ[index + startIndexInter]
                    );

                    Controlled X(
                        [intermediateValuesAuD[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesAuD[index + startIndexInter]
                    );

                }
                
                
                // copy new value in curr value but reuse areTheSame
                for index in 0..fixedBiggestSize - 1{
                    andGate(newAQ[index], 
                        intermediateValuesAQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesAQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newAQ[index], intermediateValuesAQ[index + startIndexInter], areTheSame); // puts it back in 0 state

                    andGate(newBQ[index], 
                        intermediateValuesBQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesBQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newBQ[index], intermediateValuesBQ[index + startIndexInter], areTheSame); // puts it back in 0 state

                    andGate(newAuxDiv[index], 
                        intermediateValuesAuD[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesAuD[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newAuxDiv[index], intermediateValuesAuD[index + startIndexInter], areTheSame); // puts it back in 0 state

                }

                // reverse the pebbling so that new value is back to 0 for the next step
                pebbleGCDStep(
                    intermediateValuesAQ[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    intermediateValuesBQ[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    newAQ, newBQ, newAuxDiv, true
                );
                
                // make sure that the next current value is the new value computed at this step (which we stored) in intermediate
                // values
                for index in 0..fixedBiggestSize - 1 {
                    SWAP(intermediateValuesAQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesAQ[startIndexInter + index]);

                    SWAP(intermediateValuesBQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesBQ[startIndexInter + index]);

                    SWAP(intermediateValuesAuD[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesAuD[startIndexInter + index]);
                }

                set tempArr w/= nextIndex <- startIndexInter;
                
            }

            
            set tempArr = unpebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesAQ, 
                intermediateValuesBQ, intermediateValuesAuD, newAQ, newBQ, newAuxDiv,
                result, control, areTheSame, fixedBiggestSize, reversing);

            if(tempArr[targetIndex] != -1 or nextIndex < targetIndex){
                set tempArr = pebbleStep(nextIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesAQ, 
                intermediateValuesBQ, intermediateValuesAuD, newAQ, newBQ, newAuxDiv,
                result, control, areTheSame, fixedBiggestSize, reversing);            
            }
        }

        return tempArr;
    }

    // given a quantum register, the operation computes the value stored in it
    // can be used as long as the register is not in an entagled state with a different
    // register as that will collapse both of their states
    operation computeValue(arrQ: Qubit[]): Int {
        mutable result = 0;
        mutable power = 1;
        for index in 0..Length(arrQ) - 1{
            use temp = Qubit();
            Controlled X([arrQ[index]], temp);
            let res = MeasureInteger(LittleEndian([temp]));
            if(res == 1){
                set result = result + power;
            }
            set power = power * 2;
        }
        return result;
    }

    // the unpebbling step operation which is identical to the one mentioned in the report in algorithm 1
    operation unpebbleStep(currentIndex: Int, maximumIndex: Int, targetIndex: Int, indexArr: Int[],
                            intermediateValuesAQ: Qubit[], intermediateValuesBQ: Qubit[], intermediateValuesAuD: Qubit[], 
                            newAQ: Qubit[], newBQ: Qubit[], newAuxDiv: Qubit[],
                            result: Qubit[], control: Qubit, areTheSame: Qubit, fixedBiggestSize: Int,
                            reversing: Bool): Int[] {
        
        mutable tempArr = indexArr;

        if(maximumIndex != 0){
            let nextIndex = currentIndex + PowI(2, maximumIndex - 1);
            set tempArr = unpebbleStep(nextIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesAQ, 
                intermediateValuesBQ, intermediateValuesAuD, newAQ, newBQ, newAuxDiv,
                result, control, areTheSame, fixedBiggestSize, reversing);     

            set tempArr = pebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesAQ, 
                intermediateValuesBQ, intermediateValuesAuD, newAQ, newBQ, newAuxDiv,
                result, control, areTheSame, fixedBiggestSize, reversing);       

            if(nextIndex < targetIndex){
                let startIndexInter = tempArr[nextIndex];
                set tempArr w/= nextIndex <- -1;
                // reverse the operation (same as removing a pebble)
                pebbleGCDStep(
                    intermediateValuesAQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)], 
                    intermediateValuesBQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)], 
                    intermediateValuesAQ[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    intermediateValuesBQ[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    intermediateValuesAuD[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    true
                );
                
            }   

            set tempArr = unpebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesAQ, 
                intermediateValuesBQ, intermediateValuesAuD, newAQ, newBQ, newAuxDiv,
                result, control, areTheSame, fixedBiggestSize, reversing);
        
        }

        return tempArr;
    }

    // operation used to set up a superposition of values using the Hadamard gat
    // so that the operation can be checked when running in superposition
    // also provides a good estimate for the number of qubits required when running
    // the resource estimator
    operation testGCDQubitCount(registerSize: Int): Unit{
        use aQ = Qubit[registerSize];
        use bQ = Qubit[registerSize];
        use resQ = Qubit[registerSize];

        ApplyToEach(H, aQ);
        ApplyToEach(H, bQ);

        GCD(aQ, bQ, resQ, false);
        GCD(aQ, bQ, resQ, true);

        ApplyToEach(H, aQ);
        ApplyToEach(H, bQ);

    }

}