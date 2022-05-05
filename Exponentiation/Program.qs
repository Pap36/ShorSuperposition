namespace Exponentiation.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;    
    open Microsoft.Quantum.Logical;
    open ExponentiationStep.Testing;

    // operation used to numerically check the validity of the implementation
    // given a, b and c the operation returns a^b mod c
    operation testExpo(a: BigInt, b: BigInt, c: BigInt) : Int {
        
        // initialise the quantum registers in state |a>|b>|c>
        let aB = BigIntAsBoolArray(a);
        use aQ = Qubit[Length(aB)];
        for index in 0..Length(aB) - 1 {
            if(aB[index]) {
                X(aQ[index]);
            }
        }

        let bB = BigIntAsBoolArray(b);
        mutable bSize = 0;
        for index in 0..Length(bB) - 1 {
            if(bB[index]){
                set bSize = index + 1;
            }
        }

        // remember that b is reversed
        use bQ = Qubit[bSize];
        for index in 0..bSize - 1 {
            if(bB[index]) {
                X(bQ[bSize - 1 - index]);
            }
        }
        
        let cB = BigIntAsBoolArray(c);
        use cQ = Qubit[Length(cB)];
        for index in 0..Length(cB) - 1 {
            if(cB[index]) {
                X(cQ[index]);
            }
        }
        
        // prepare quantum regoster in state |1> for the result
        // state |1> because of QPE afterwards
        use resQ = Qubit[Max([Length(aQ), Length(cQ)])];
        
        // use one = Qubit();
        // X(one);
        // AddI(LittleEndian([one]), LittleEndian(resQ));
        IncrementByInteger(1, LittleEndian(resQ));


        Exponentiation(aQ, bQ, cQ, resQ, false);

        // use auxiliary register to numerically verify the result
        use finalRes = Qubit[Max([Length(aQ), Length(cQ)])];
        AddI(LittleEndian(resQ), LittleEndian(finalRes));

        let result = MeasureInteger(LittleEndian(finalRes));
        
        // reverse the opperation
        Exponentiation(aQ, bQ, cQ, resQ, true);
        
        Adjoint IncrementByInteger(1, LittleEndian(resQ));
        // Adjoint AddI(LittleEndian([one]), LittleEndian(resQ));
        // X(one);
        //X(resQ[0]);

        for index in 0..Length(aB) - 1{
            if(aB[index]){
                X(aQ[index]);
            }
        }
        for index in 0..bSize - 1 {
            if(bB[index]) {
                X(bQ[bSize - 1 - index]);
            }
        }
        for index in 0..Length(cB) - 1{
            if(cB[index]){
                X(cQ[index]);
            }
        }

        return result;
    }
    
    // given the quantum state |a>|b>|c>|0>, the operation returns
    // the quantum state |a>|b>|c>|a^b mod c> 
    operation Exponentiation(aQ: Qubit[], bQ: Qubit[], cQ: Qubit[], result: Qubit[], reversing: Bool): Unit {
        
        // prepare the values for the number of steps in the pebble game and
        // the required number of intermediate values to be stored according to
        // Bennet's conversion algorithm

        let target = Length(bQ); // remember that the first bit of b is descarded before
        let value = Ceiling(Log(IntAsDouble(target)) / Log(2.0) + 2.0);

        let fixedBiggestSize = Max([Length(aQ), Length(cQ)]);

        // initialise the registers for the intermediate values
        use intermediateValues = Qubit[fixedBiggestSize * (value - 1)];
        
        // make sure that the first value stored in the intermediates is the initial value
        for index in 0..Length(aQ) - 1{
            Controlled X([aQ[index]], intermediateValues[index]);
        }

        // prepare classical array which keeps track of which slots are occupied
        mutable indexArr = [-1, size = target + 2];
        set indexArr w/= 0 <- 0;

        // initialise the registers for the new values (output after every pebbling step)
        use newValue = Qubit[fixedBiggestSize];
        
        // control qubit to check if the result has been fount + qubit used in the 
        // AND gate
        use controlQ = Qubit();
        use areTheSame = Qubit();

        // start the pebbling algorithm
        set indexArr = pebbleStep(0, value - 1, target, indexArr, bQ, intermediateValues, aQ, cQ,
            newValue, result, controlQ, areTheSame, fixedBiggestSize, reversing);
        
        X(controlQ); // because the result was hopefully found, controlQ should be 1

        // reset the original value stored in the intermediate array back to 0
        for index in 0..Length(aQ) - 1{
            Adjoint Controlled X([aQ[index]], intermediateValues[index]);
        }

    }

    // operation takes as input |a>|b>|0> and returns |a>|b>|a AND b>
    operation andGate(qubit1: Qubit, qubit2: Qubit, qubit3: Qubit): Unit is Adj + Ctl {
        Controlled X([qubit1], qubit3);
        Controlled X([qubit2], qubit3);
    }

    
    // classical operation which reflects the PebbleStep function described in the report in Algorithm 1
    // operation returns an array of integers representing the state of the indexes array
    operation pebbleStep(currentIndex: Int, maximumIndex: Int, targetIndex: Int, indexArr: Int[],
                            bQ: Qubit[], intermediateValues: Qubit[], aQ: Qubit[], cQ: Qubit[], 
                            newValue: Qubit[], result: Qubit[], control: Qubit, areTheSame: Qubit, 
                            fixedBiggestSize: Int, reversing: Bool): Int[] {
        mutable tempArr = indexArr; // the indexes array which we will modify and return
        
        // all steps are identical to the algorithm in the report 
        if(maximumIndex != 0) {
            let nextIndex = currentIndex + PowI(2, maximumIndex - 1);
            set tempArr = pebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, bQ, intermediateValues,
                 aQ, cQ, newValue, result, control, areTheSame, fixedBiggestSize, reversing);
            
            mutable startIndexInter = 0;
            
            if(tempArr[targetIndex] != -1 or nextIndex < targetIndex){
                
                // place a pebble
                SingleStep(aQ, bQ[nextIndex], cQ, 
                    intermediateValues[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)], newValue);
                
                // check if the result has been found
                if(nextIndex == targetIndex - 1){
                    // use a temporary qubit to verify if we have already found the result or not
                    // prevents from adding the result to the target register more than once
                    // also remember thaty result is in state |1>
                    use temp = Qubit();
                    Controlled X([control], temp);
                    X(control);
                    if(not reversing){
                        // use one = Qubit();
                        // X(one);
                        // Controlled Adjoint AddI([control], (LittleEndian([one]), LittleEndian(result)));
                        // X(one);
                        Controlled Adjoint IncrementByInteger([control], (1, LittleEndian(result)));
                        Controlled AddI([control], (LittleEndian(newValue), LittleEndian(result)));
                        
                    } else {
                        Controlled Adjoint AddI([control], (LittleEndian(newValue), LittleEndian(result)));
                        // use one = Qubit();
                        // X(one);
                        // Controlled AddI([control], (LittleEndian([one]), LittleEndian(result)));
                        // X(one);
                        Controlled IncrementByInteger([control], (1, LittleEndian(result)));
                    }
                    let value = MeasureInteger(LittleEndian([temp]));
                    if(value == 1){
                        X(control);
                    }
                } 
                
                // cppy all curr value in intermediate values
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
                    Controlled X([intermediateValues[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                    intermediateValues[index + startIndexInter]);
                }
                
                // copy new value in curr value but reuse areTheSame
                for index in 0..fixedBiggestSize - 1{
                    andGate(newValue[index], 
                        intermediateValues[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValues[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newValue[index], intermediateValues[index + startIndexInter], areTheSame); // puts it back in 0 state
                    }

                // reverse the pebbling so that new value is back to 0 for the next step
                Adjoint SingleStep(aQ, bQ[nextIndex], cQ, 
                    intermediateValues[startIndexInter..(startIndexInter + fixedBiggestSize - 1)], newValue);
                
                // make sure that the next current value is the new value computed at this step (which we stored) in intermediate
                // values
                for index in 0..fixedBiggestSize - 1 {
                    SWAP(intermediateValues[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValues[startIndexInter + index]);
                }

                set tempArr w/= nextIndex <- startIndexInter;
                
                
            }

            set tempArr = unpebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, bQ,
             intermediateValues, aQ, cQ, newValue, result, control, areTheSame, fixedBiggestSize, reversing);

            if(tempArr[targetIndex] != -1 or nextIndex < targetIndex){
                set tempArr = pebbleStep(nextIndex, maximumIndex - 1, targetIndex, tempArr, bQ,
                 intermediateValues, aQ, cQ, newValue, result, control, areTheSame, fixedBiggestSize, reversing);
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
                            bQ: Qubit[], intermediateValues: Qubit[], aQ: Qubit[], cQ: Qubit[],
                            newValue: Qubit[], result: Qubit[], control: Qubit, areTheSame: Qubit,
                            fixedBiggestSize: Int, reversing: Bool): Int[] {
        mutable tempArr = indexArr;

        if(maximumIndex != 0){
            let nextIndex = currentIndex + PowI(2, maximumIndex - 1);
            set tempArr = unpebbleStep(nextIndex, maximumIndex - 1, targetIndex, tempArr, bQ, intermediateValues,
             aQ, cQ, newValue, result, control, areTheSame, fixedBiggestSize, reversing);
            set tempArr = pebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, bQ, intermediateValues,
             aQ, cQ, newValue, result, control, areTheSame, fixedBiggestSize, reversing);

            if(nextIndex < targetIndex){
                let startIndexInter = tempArr[nextIndex];
                set tempArr w/= nextIndex <- -1;
                // reverse the operation (same as removing a pebble)
                Adjoint SingleStep(aQ, bQ[nextIndex], cQ, 
                    intermediateValues[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)], 
                    intermediateValues[startIndexInter..(startIndexInter + fixedBiggestSize - 1)]);
                
            }   

            set tempArr = unpebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, bQ, intermediateValues,
             aQ, cQ, newValue, result, control, areTheSame, fixedBiggestSize, reversing);
        
        }

        return tempArr;
    }

    // operation used to set up a superposition of values using the Hadamard gat
    // so that the operation can be checked when running in superposition
    // also provides a good estimate for the number of qubits required when running
    // the resource estimator
    operation testExpoQubitCount(registerSize: Int): Unit{
        use aQ = Qubit[registerSize];
        use bQ = Qubit[registerSize];
        use cQ = Qubit[registerSize];
        use resQ = Qubit[registerSize];

        ApplyToEach(H, aQ);
        ApplyToEach(H, bQ);
        ApplyToEach(H, cQ);

        Exponentiation(aQ, bQ, cQ, resQ, false);
        
        Exponentiation(aQ, bQ, cQ, resQ, true);

        ApplyToEach(H, aQ);
        ApplyToEach(H, bQ);
        ApplyToEach(H, cQ);


    }

}