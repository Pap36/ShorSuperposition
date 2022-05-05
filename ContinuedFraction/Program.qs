namespace ContinuedFraction.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;    
    open Microsoft.Quantum.Logical;
    open ContinuedFractionStep.Testing;

    operation testCFQubitCount(registerSize: Int): Unit{
        use aQ = Qubit[2 * registerSize + 1];
        use bQ = Qubit[2 * registerSize + 1];
        use cQ = Qubit[registerSize];
        use resQ = Qubit[registerSize];

        ApplyToEach(H, aQ);
        ApplyToEach(H, bQ);
        ApplyToEach(H, cQ);

        CF(aQ, bQ, cQ, resQ, false);
        CF(aQ, bQ, cQ, resQ, true);


    }

    operation testCF(a: BigInt, b: BigInt, c: BigInt) : Int {
        // Message("Hello");
        let aB = BigIntAsBoolArray(a);
        let bB = BigIntAsBoolArray(b);
        let cB = BigIntAsBoolArray(c);

        mutable size = 0;
        for index in 0..Length(bB) - 1 {
            if(bB[index]){
                set size = index + 1;
            }
        }

        use aQ = Qubit[size];
        for index in 0..Length(aB) - 1 {
            if(aB[index]) {
                X(aQ[index]);
            }
        }

        
        use bQ = Qubit[size];
        for index in 0..size - 1 {
            if(bB[index]) {
                X(bQ[index]);
            }
        }
        
        use cQ = Qubit[(size - 1) / 2];
        for index in 0..Length(cB) - 1 {
            if(cB[index]) {
                X(cQ[index]);
            }
        }

        use resQ = Qubit[(size - 1) / 2]; // this might need to be changed
        // approximate aQ/bQ up to cQ as a bound in result
        // Message("Before func we have " + IntAsString(computeValue(aQ)) + " " + IntAsString(computeValue(bQ)) + 
        //     " " + IntAsString(computeValue(cQ)) + " " + IntAsString(computeValue(resQ)) + " " + IntAsString(computeValue(garbage))
        // );
        CF(aQ, bQ, cQ, resQ, false);
        
        // Message("After func we have " + IntAsString(computeValue(aQ)) + " " + IntAsString(computeValue(bQ)) + 
        //     " " + IntAsString(computeValue(cQ)) + " " + IntAsString(computeValue(resQ)) + " " + IntAsString(computeValue(garbage))
        // );
        use finalRes = Qubit[Length(resQ)];
        AddI(LittleEndian(resQ), LittleEndian(finalRes));

        let result = MeasureInteger(LittleEndian(finalRes));
        CF(aQ, bQ, cQ, resQ, true);
        
        // Message("After reverse func we have " + IntAsString(computeValue(aQ)) + " " + IntAsString(computeValue(bQ)) + 
        //     " " + IntAsString(computeValue(cQ)) + " " + IntAsString(computeValue(resQ)) + " " + IntAsString(computeValue(garbage))
        // );

        for index in 0..Length(aB) - 1 {
            if(aB[index]) {
                X(aQ[index]);
            }
        }

        for index in 0..size - 1 {
            if(bB[index]) {
                X(bQ[index]);
            }
        }
        
        for index in 0..Length(cB) - 1 {
            if(cB[index]) {
                X(cQ[index]);
            }
        }

        //Message("Here");

        return result;
    }
    
    operation CF(kQ: Qubit[], mQ: Qubit[], nQ: Qubit[], result: Qubit[], reversing: Bool): Unit {
        // nQ is the bound
        // mQ > nQ * nQ
        let target = Ceiling(IntAsDouble(Length(result)) * 1.44);
        let value = Ceiling(Log(IntAsDouble(target)) / Log(2.0) + 2.0);

        //let fixedBiggestSize = Max([Length(kQ), Length(nQ), Length(mQ)]);
        let fixedBiggestSize = Length(result);

        use intermediateValuesNQ = Qubit[fixedBiggestSize * (value - 1)];
        use intermediateValuesDQ = Qubit[fixedBiggestSize * (value - 1)];
        
        use intermediateValuesNPad1 = Qubit[(fixedBiggestSize + 1) * (value - 1)];
        use intermediateValuesNPad2 = Qubit[(fixedBiggestSize + 1) * (value - 1)];
        
        use intermediateValuesAD1 = Qubit[fixedBiggestSize * (value - 1)];
        use intermediateValuesAD2 = Qubit[fixedBiggestSize * (value - 1)];
        use intermediateValuesAuD = Qubit[fixedBiggestSize * (value - 1)];
        use intermediateValuesAuM = Qubit[fixedBiggestSize * (value - 1)];
        use intermediateValuesP = Qubit[fixedBiggestSize * (value - 1)];
        use intermediateValuesP1 = Qubit[(fixedBiggestSize + 1) * (value - 1)];

        use nPad1 = Qubit[fixedBiggestSize + 1];
        use nPad2 = Qubit[fixedBiggestSize + 1];

        use newNQ = Qubit[fixedBiggestSize];
        use newDQ = Qubit[fixedBiggestSize];
        use newApproxDenom1 = Qubit[fixedBiggestSize];
        use newApproxDenom2 = Qubit[fixedBiggestSize];
        use newAuxDiv = Qubit[fixedBiggestSize];
        use newAuxMult = Qubit[fixedBiggestSize];
        use newPad = Qubit[fixedBiggestSize];
        use nP1 = Qubit[fixedBiggestSize + 1];
        
        
        // make sure first value in intermediate is aQ
        // the first values in intermediate will be
        // k, m, apD1=0, apD2=0, auxD=0, auxM=0, pad=0
        // this also entails kQ and mQ are the same length
        for index in 0..fixedBiggestSize - 1{
            Controlled X([kQ[index]], intermediateValuesNQ[index]);
            Controlled X([mQ[index]], intermediateValuesDQ[index]);
        }

        for index in fixedBiggestSize..2*fixedBiggestSize{
            Controlled X([kQ[index]], intermediateValuesNPad1[index - fixedBiggestSize]);
            Controlled X([mQ[index]], intermediateValuesNPad2[index - fixedBiggestSize]);
        }

        mutable indexArr = [-1, size = target + 2];
        set indexArr w/= 0 <- 0;

        use controlQ = Qubit();
        use areTheSame = Qubit();
        //use boundPad = Qubit[2 * fixedBiggestSize - Length(nQ)];
        
        set indexArr = pebbleStep(0, value - 1, target, indexArr, intermediateValuesNQ, 
                intermediateValuesDQ, intermediateValuesAD1, intermediateValuesAD2, intermediateValuesAuD, intermediateValuesAuM,
                intermediateValuesP, intermediateValuesNPad1, intermediateValuesNPad2, intermediateValuesP1, newNQ, newDQ,
                newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nPad1, nPad2, nP1,
                result, controlQ, areTheSame, fixedBiggestSize, nQ, reversing);

        //Message("Am here and the final values are");
        
        X(controlQ);

        // make sure first value in intermediate is aQ
        for index in 0..fixedBiggestSize - 1{
            Adjoint Controlled X([kQ[index]], intermediateValuesNQ[index]);
            Adjoint Controlled X([mQ[index]], intermediateValuesDQ[index]);
        }

        for index in fixedBiggestSize..2*fixedBiggestSize{
            Adjoint Controlled X([kQ[index]], intermediateValuesNPad1[index - fixedBiggestSize]);
            Adjoint Controlled X([mQ[index]], intermediateValuesNPad2[index - fixedBiggestSize]);
        }

        // Message("WTF " + IntAsString(computeValue([controlQ])));
        

    }

    operation andGate(qubit1: Qubit, qubit2: Qubit, qubit3: Qubit): Unit is Adj + Ctl {
        Controlled X([qubit1], qubit3);
        Controlled X([qubit2], qubit3);
    }

    operation ApplyToEachX(target: Qubit[]) : Unit is Adj + Ctl{
        for index in 0..Length(target) - 1{
            X(target[index]);
        }
    }

    operation pebbleCFStep(currNQ: Qubit[], currDQ: Qubit[], currApproxDenom1: Qubit[], currApproxDenom2: Qubit[], 
        newNQ: Qubit[], newDQ: Qubit[], newApproxDenom1: Qubit[],
        newApproxDenom2: Qubit[], newAuxDiv: Qubit[], newAuxMult: Qubit[], newPad: Qubit[], nP1: Qubit[],
        convergenceIndex: Int, adj: Bool): Unit{
        
        //Message("Issue at convergenceIndex " + IntAsString(convergenceIndex));
        // all new values are 0 and so is curr aux
        // we add all curr values to new values then call CFStep on the new values
        if(not adj){
            AddI(LittleEndian(currNQ), LittleEndian(newNQ));
            AddI(LittleEndian(currDQ), LittleEndian(newDQ));
            AddI(LittleEndian(currApproxDenom1), LittleEndian(newApproxDenom1));
            AddI(LittleEndian(currApproxDenom2), LittleEndian(newApproxDenom2));
            
            // change the 0 division - mus
            let zeroDiv = computeValue(currDQ);
            if(zeroDiv != 0){
                CFStep(newNQ, newDQ, newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nP1, convergenceIndex);
            }
        } else {
            // change the 0 division - mus
            let zeroDiv = computeValue(currDQ);
            if(zeroDiv != 0){
                //Message(IntAsString(computeValue(newDQ)));
                Adjoint CFStep(newNQ, newDQ, newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nP1, convergenceIndex);
            }

            Adjoint AddI(LittleEndian(currNQ), LittleEndian(newNQ));
            Adjoint AddI(LittleEndian(currDQ), LittleEndian(newDQ));
            Adjoint AddI(LittleEndian(currApproxDenom1), LittleEndian(newApproxDenom1));
            Adjoint AddI(LittleEndian(currApproxDenom2), LittleEndian(newApproxDenom2));
        }
        //Message("Here");
        //Message("After");
    }

    operation garbageAddition(toAdd: Qubit[], target: Qubit[], control: Qubit, reversing: Bool): Unit {
        // add to target only if target is not 0
        use temp = Qubit();
        Controlled X([control], temp);
        X(control);
        if(not reversing){
            Controlled AddI([control], (LittleEndian(toAdd), LittleEndian(target)));
        } else {
            Controlled Adjoint AddI([control], (LittleEndian(toAdd), LittleEndian(target)));
        }
        let value = MeasureInteger(LittleEndian([temp]));
        if(value == 1){
            X(control);
        }

        // if(not reversing){
            
        //     ApplyToEachX(garbageCollector);
        //     Controlled AddI(garbageCollector, (LittleEndian(toAdd), LittleEndian(target)));
        //     ApplyToEachX(garbageCollector);
        //     use one = Qubit();
        //     X(one);
        //     AddI(LittleEndian([one]), LittleEndian(garbageCollector));
        //     X(one);
        // } else {
        //     use one = Qubit();
        //     X(one);
        //     Adjoint AddI(LittleEndian([one]), LittleEndian(garbageCollector));
        //     X(one);

        //     ApplyToEachX(garbageCollector);
        //     Controlled Adjoint AddI(garbageCollector, (LittleEndian(toAdd), LittleEndian(target)));
        //     ApplyToEachX(garbageCollector);
            
        // }
        
    }

    operation pebbleStep(currentIndex: Int, maximumIndex: Int, targetIndex: Int, indexArr: Int[],
                            intermediateValuesNQ: Qubit[], intermediateValuesDQ: Qubit[], intermediateValuesAD1: Qubit[],
                            intermediateValuesAD2: Qubit[], intermediateValuesAuD: Qubit[], intermediateValuesAuM: Qubit[],
                            intermediateValuesP: Qubit[], intermediateValuesNPad1: Qubit[], intermediateValuesNPad2: Qubit[],
                            intermediateValuesP1: Qubit[],
                            newNQ: Qubit[], newDQ: Qubit[], newApproxDenom1: Qubit[], newApproxDenom2: Qubit[], 
                            newAuxDiv: Qubit[], newAuxMult: Qubit[], newPad: Qubit[], nPad1: Qubit[], nPad2: Qubit[], nP1: Qubit[],
                            result: Qubit[], control: Qubit, areTheSame: Qubit, fixedBiggestSize: Int, bound: Qubit[],
                            reversing: Bool): Int[] {
        
        mutable tempArr = indexArr;
        

        if(maximumIndex != 0) {
            let nextIndex = currentIndex + PowI(2, maximumIndex - 1);
            set tempArr = pebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesNQ, 
                intermediateValuesDQ, intermediateValuesAD1, intermediateValuesAD2, intermediateValuesAuD, intermediateValuesAuM,
                intermediateValuesP, intermediateValuesNPad1, intermediateValuesNPad2, intermediateValuesP1, newNQ, newDQ, 
                newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nPad1, nPad2, nP1,
                result, control, areTheSame, fixedBiggestSize, bound, reversing);
            
            mutable startIndexInter = 0;
            
            if(tempArr[targetIndex] != -1 or nextIndex < targetIndex){
                // need to place the pebble here
                // every current value will be retrieved from its corresponding intermediateValues array
                // Message("Before the cont frac step we have the values:\ncurrNQ: " + 
                //     IntAsString(computeValue(intermediateValuesNQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)] +
                //     intermediateValuesNPad1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                //     ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)])) + "\ncurrDQ: " + 
                //     IntAsString(computeValue(intermediateValuesDQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)] +
                //     intermediateValuesNPad2[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                //     ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)])) + "\ncurrAD1: " + 
                //     IntAsString(computeValue(intermediateValuesAD1[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + 
                //         fixedBiggestSize - 1)])) + "\ncurrAD2: " +
                //     IntAsString(computeValue(intermediateValuesAD2[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + 
                //         fixedBiggestSize - 1)])) + "\n\nnewNQ: " + IntAsString(computeValue(newNQ + nPad1)) + "\nnewDQ: " +
                //     IntAsString(computeValue(newDQ + nPad2)) + "\nnewAD1: " + IntAsString(computeValue(newApproxDenom1)) +
                //     "\nnewAD2: " + IntAsString(computeValue(newApproxDenom2)) + "\nnewAuD: " + IntAsString(
                //         computeValue(newAuxDiv)) + "\nnewAuM: " + IntAsString(computeValue(newAuxMult)) + "\nnewPad: " +
                //     IntAsString(computeValue(newPad))
                // );


                pebbleCFStep(intermediateValuesNQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)] +
                             intermediateValuesNPad1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                             ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)],
                             intermediateValuesDQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)] +
                             intermediateValuesNPad2[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                             ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)],
                             intermediateValuesAD1[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)],
                             intermediateValuesAD2[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)],
                             newNQ + nPad1, newDQ + nPad2, newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nP1,
                             nextIndex - 1, false);

                // Message("After the cont frac step we have the values:\ncurrNQ: " + 
                //     IntAsString(computeValue(intermediateValuesNQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)] +
                //     intermediateValuesNPad1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                //     ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)])) + "\ncurrDQ: " + 
                //     IntAsString(computeValue(intermediateValuesDQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)] +
                //     intermediateValuesNPad2[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                //     ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)])) + "\ncurrAD1: " + 
                //     IntAsString(computeValue(intermediateValuesAD1[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + 
                //         fixedBiggestSize - 1)])) + "\ncurrAD2: " +
                //     IntAsString(computeValue(intermediateValuesAD2[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + 
                //         fixedBiggestSize - 1)])) + "\n\nnewNQ: " + IntAsString(computeValue(newNQ + nPad1)) + "\nnewDQ: " +
                //     IntAsString(computeValue(newDQ + nPad2)) + "\nnewAD1: " + IntAsString(computeValue(newApproxDenom1)) +
                //     "\nnewAD2: " + IntAsString(computeValue(newApproxDenom2)) + "\nnewAuD: " + IntAsString(
                //         computeValue(newAuxDiv)) + "\nnewAuM: " + IntAsString(computeValue(newAuxMult)) + "\nnewPad: " +
                //     IntAsString(computeValue(newPad))
                // );

                // this needs to be redone
                // we add it to the target register when nextIndex == targetIndex or when
                // newDQ == 0 or when
                // newApproxDenom2 > bound
                // if(nextIndex == targetIndex - 1){
                //     X(control);
                //     // RESULT WILL NEED TO BE 2L because of this
                //     Controlled AddI([control], (LittleEndian(newApproxDenom1 + newPad), LittleEndian(result)));
                    
                //     // we turn control back, only if result is 0 <==> X(result) is 1
                //     ApplyToEach(X, result);
                //     Controlled X(result, control);
                //     ApplyToEach(X, result);

                // }

                // Message("Before checking we have:\nnewDQ: " + IntAsString(computeValue(newDQ)) + "\nnewAD1: " +
                //     IntAsString(computeValue(newApproxDenom1)) + "\nnewAD2: " + IntAsString(computeValue(newApproxDenom2)) +
                //     "\nresult: " + IntAsString(computeValue(result)) + "\ncontrol: " + IntAsString(computeValue([control]))
                // );

                use greater = Qubit();
                use bPad = Qubit[Length(newPad)];
                //Message(IntAsString(computeValue(newApproxDenom1 + newPad)) + " " + IntAsString(computeValue(bound + bPad)));
                GreaterThan(LittleEndian(newApproxDenom1 + newPad), LittleEndian(bound + bPad), greater);
                let greaterValue = MeasureInteger(LittleEndian([greater]));
                let denomVal = computeValue(newDQ);
                // greater becomes 1 if newAppD2 > bound

                // Message("The values of newApproxDenom1, newApproxDenom2, bound and greater are " + 
                //     IntAsString(computeValue(newApproxDenom1 + newPad)) + " " +IntAsString(computeValue(newApproxDenom2)) + 
                //     " " + IntAsString(computeValue(bound + bPad)) + " " + IntAsString(computeValue([greater]))
                // );

                if(greaterValue == 1){
                    // try adding d2 to result if not already added
                    use temp = Qubit();
                    Controlled X([control], temp);
                    X(control);
                    if(not reversing){
                        Controlled AddI([control], (LittleEndian(newApproxDenom2[0..Length(result) - 1]), LittleEndian(result)));
                    } else {
                        Controlled Adjoint AddI([control], (LittleEndian(newApproxDenom2[0..Length(result) - 1]), LittleEndian(result)));
                    }
                    let value = MeasureInteger(LittleEndian([temp]));
                    if(value == 1){
                        X(control);
                    }
                } elif(denomVal == 0) {
                    use temp = Qubit();
                    Controlled X([control], temp);
                    X(control);
                    if(not reversing){
                        Controlled AddI([control], (LittleEndian(newApproxDenom1[0..Length(result) - 1]), LittleEndian(result)));
                    } else {
                        Controlled Adjoint AddI([control], (LittleEndian(newApproxDenom1[0..Length(result) - 1]), LittleEndian(result)));
                    }
                    let value = MeasureInteger(LittleEndian([temp]));
                    if(value == 1){
                        X(control);
                    }
                    // need to add d1 + newPad to result otherwise
                    // but only if the denom is 0 and if I have not already added it (control)
                }
                
                //Controlled garbageAddition([greater], (newApproxDenom2, result, literallyGarbage, reversing));
                // Message("After checking [control, greater] we have:\nnewDQ: " + IntAsString(computeValue(newDQ)) + "\nnewAD1: " +
                //     IntAsString(computeValue(newApproxDenom1)) + "\nnewAD2: " + IntAsString(computeValue(newApproxDenom2)) +
                //     "\nresult: " + IntAsString(computeValue(result)) + "\ncontrol: " + IntAsString(computeValue([control]))
                // );
                
                // ApplyToEach(X, newDQ);

                // Controlled garbageAddition([greater] + newDQ, (newApproxDenom1 + newPad, result, literallyGarbage, reversing));
                // Message("After checking [control, greater + newDQ] we have:\nnewDQ: " + IntAsString(computeValue(newDQ)) + "\nnewAD1: " +
                //     IntAsString(computeValue(newApproxDenom1)) + "\nnewAD2: " + IntAsString(computeValue(newApproxDenom2)) +
                //     "\nresult: " + IntAsString(computeValue(result)) + "\ncontrol: " + IntAsString(computeValue([control])) + "\n"
                // );

                // ApplyToEach(X, newDQ);

                // Adjoint GreaterThan(LittleEndian(newApproxDenom1 + newPad), LittleEndian(bound), greater);
                
                // Message("After checking we have:\nnewDQ: " + IntAsString(computeValue(newDQ)) + "\nnewAD1: " +
                //     IntAsString(computeValue(newApproxDenom1)) + "\nnewAD2: " + IntAsString(computeValue(newApproxDenom2)) +
                //     "\nresult: " + IntAsString(computeValue(result)) + "\ncontrol: " + IntAsString(computeValue([control])) + "\n"
                // );

                // coppy curr value in intermediate values
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

                for index in 0..fixedBiggestSize{
                    Controlled X(
                        [intermediateValuesNPad1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index]],
                        intermediateValuesNPad1[index + startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1)]
                    );

                    Controlled X(
                        [intermediateValuesNPad2[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index]],
                        intermediateValuesNPad2[index + startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1)]
                    );

                    Controlled X(
                        [intermediateValuesP1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index]],
                        intermediateValuesP1[index + startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1)]
                    );
                }
                
                // Bad Code I know ... :( 
                for index in 0..fixedBiggestSize - 1{
                    Controlled X(
                        [intermediateValuesNQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesNQ[index + startIndexInter]
                    );

                    Controlled X(
                        [intermediateValuesDQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesDQ[index + startIndexInter]
                    );

                    Controlled X(
                        [intermediateValuesAD1[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesAD1[index + startIndexInter]
                    );

                    Controlled X(
                        [intermediateValuesAD2[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesAD2[index + startIndexInter]
                    );

                    Controlled X(
                        [intermediateValuesAuD[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesAuD[index + startIndexInter]
                    );

                    Controlled X(
                        [intermediateValuesAuM[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesAuM[index + startIndexInter]
                    );

                    Controlled X(
                        [intermediateValuesP[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]],
                        intermediateValuesP[index + startIndexInter]
                    );
                }
                
                for index in 0..fixedBiggestSize{
                    andGate(nPad1[index], 
                        intermediateValuesNPad1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index], 
                        areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesNPad1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index]);
                    Adjoint andGate(nPad1[index], 
                    intermediateValuesNPad1[index + (startIndexInter) / fixedBiggestSize * (fixedBiggestSize + 1)], areTheSame); 
                    // puts it back in 0 state

                    andGate(nPad2[index], 
                        intermediateValuesNPad2[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index], 
                        areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesNPad2[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index]);
                    Adjoint andGate(nPad2[index], 
                    intermediateValuesNPad2[index + (startIndexInter) / fixedBiggestSize * (fixedBiggestSize + 1)], areTheSame); 
                    // puts it back in 0 state

                    andGate(nP1[index], 
                        intermediateValuesP1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index], 
                        areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesP1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index]);
                    Adjoint andGate(nP1[index], 
                    intermediateValuesP1[index + (startIndexInter) / fixedBiggestSize * (fixedBiggestSize + 1)], areTheSame); 
                    // puts it back in 0 state

                }
                
                for index in 0..fixedBiggestSize - 1{
                    // copy new value in curr value but reuse areTheSame
                    andGate(newNQ[index], 
                        intermediateValuesNQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesNQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newNQ[index], intermediateValuesNQ[index + startIndexInter], areTheSame); // puts it back in 0 state

                    andGate(newDQ[index], 
                        intermediateValuesDQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesDQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newDQ[index], intermediateValuesDQ[index + startIndexInter], areTheSame); // puts it back in 0 state

                    andGate(newApproxDenom1[index], 
                        intermediateValuesAD1[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesAD1[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newApproxDenom1[index], intermediateValuesAD1[index + startIndexInter], areTheSame); // puts it back in 0 state

                    andGate(newApproxDenom2[index], 
                        intermediateValuesAD2[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesAD2[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newApproxDenom2[index], intermediateValuesAD2[index + startIndexInter], areTheSame); // puts it back in 0 state

                    andGate(newAuxDiv[index], 
                        intermediateValuesAuD[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesAuD[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newAuxDiv[index], intermediateValuesAuD[index + startIndexInter], areTheSame); // puts it back in 0 state

                    andGate(newAuxMult[index], 
                        intermediateValuesAuM[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesAuM[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newAuxMult[index], intermediateValuesAuM[index + startIndexInter], areTheSame); // puts it back in 0 state

                    andGate(newPad[index], 
                        intermediateValuesP[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], areTheSame);
                    Controlled X([areTheSame], 
                        intermediateValuesP[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index]);
                    Adjoint andGate(newPad[index], intermediateValuesP[index + startIndexInter], areTheSame); // puts it back in 0 state
                }

                // we Still need to make newValue be equal to 0
                pebbleCFStep(
                    intermediateValuesNQ[startIndexInter..(startIndexInter + fixedBiggestSize - 1)] + 
                    intermediateValuesNPad1[(startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1))..
                    ((startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)],
                    intermediateValuesDQ[startIndexInter..(startIndexInter + fixedBiggestSize - 1)]+ 
                    intermediateValuesNPad2[(startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1))..
                    ((startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)],
                    intermediateValuesAD1[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    intermediateValuesAD2[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    newNQ + nPad1, newDQ + nPad2, newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult,
                    newPad, nP1, nextIndex - 1, true
                );

                for index in 0..fixedBiggestSize{
                    SWAP(intermediateValuesNPad1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index], 
                        intermediateValuesNPad1[startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1) + index]);
                    
                    SWAP(intermediateValuesNPad2[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index], 
                        intermediateValuesNPad2[startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1) + index]);

                    SWAP(intermediateValuesP1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                        ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)][index], 
                        intermediateValuesP1[startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1) + index]);
                }
                
                for index in 0..fixedBiggestSize - 1 {
                    SWAP(intermediateValuesNQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesNQ[startIndexInter + index]);

                    SWAP(intermediateValuesDQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesDQ[startIndexInter + index]);

                    SWAP(intermediateValuesAD1[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesAD1[startIndexInter + index]);    
                    
                    SWAP(intermediateValuesAD2[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesAD2[startIndexInter + index]);

                    SWAP(intermediateValuesAuD[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesAuD[startIndexInter + index]);

                    SWAP(intermediateValuesAuM[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesAuM[startIndexInter + index]);
                    
                    SWAP(intermediateValuesP[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)][index], 
                        intermediateValuesP[startIndexInter + index]);
                }

                set tempArr w/= nextIndex <- startIndexInter;
                
            }

            
            set tempArr = unpebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesNQ, 
                intermediateValuesDQ, intermediateValuesAD1, intermediateValuesAD2, intermediateValuesAuD, intermediateValuesAuM,
                intermediateValuesP, intermediateValuesNPad1, intermediateValuesNPad2, intermediateValuesP1, newNQ, newDQ, 
                newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nPad1, nPad2, nP1,
                result, control, areTheSame, fixedBiggestSize, bound, reversing);

            if(tempArr[targetIndex] != -1 or nextIndex < targetIndex){
                set tempArr = pebbleStep(nextIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesNQ, 
                intermediateValuesDQ, intermediateValuesAD1, intermediateValuesAD2, intermediateValuesAuD, intermediateValuesAuM,
                intermediateValuesP, intermediateValuesNPad1, intermediateValuesNPad2, intermediateValuesP1, newNQ, newDQ, 
                newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nPad1, nPad2, nP1,
                result, control, areTheSame, fixedBiggestSize, bound, reversing);
            }
        }

        return tempArr;
    }

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

    operation unpebbleStep(currentIndex: Int, maximumIndex: Int, targetIndex: Int, indexArr: Int[],
                            intermediateValuesNQ: Qubit[], intermediateValuesDQ: Qubit[], intermediateValuesAD1: Qubit[],
                            intermediateValuesAD2: Qubit[], intermediateValuesAuD: Qubit[], intermediateValuesAuM: Qubit[],
                            intermediateValuesP: Qubit[], intermediateValuesNPad1: Qubit[], intermediateValuesNPad2: Qubit[],
                            intermediateValuesP1: Qubit[],
                            newNQ: Qubit[], newDQ: Qubit[], newApproxDenom1: Qubit[], newApproxDenom2: Qubit[], 
                            newAuxDiv: Qubit[], newAuxMult: Qubit[], newPad: Qubit[], nPad1: Qubit[], nPad2: Qubit[], nP1: Qubit[],
                            result: Qubit[], control: Qubit, areTheSame: Qubit, fixedBiggestSize: Int, bound: Qubit[],
                            reversing: Bool): Int[] {
        
        mutable tempArr = indexArr;

        if(maximumIndex != 0){
            let nextIndex = currentIndex + PowI(2, maximumIndex - 1);

            set tempArr = unpebbleStep(nextIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesNQ, 
                intermediateValuesDQ, intermediateValuesAD1, intermediateValuesAD2, intermediateValuesAuD, intermediateValuesAuM,
                intermediateValuesP, intermediateValuesNPad1, intermediateValuesNPad2, intermediateValuesP1, newNQ, newDQ, 
                newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nPad1, nPad2, nP1,
                result, control, areTheSame, fixedBiggestSize, bound, reversing);

            set tempArr = pebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesNQ, 
                intermediateValuesDQ, intermediateValuesAD1, intermediateValuesAD2, intermediateValuesAuD, intermediateValuesAuM,
                intermediateValuesP, intermediateValuesNPad1, intermediateValuesNPad2, intermediateValuesP1, newNQ, newDQ, 
                newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nPad1, nPad2, nP1,
                result, control, areTheSame, fixedBiggestSize, bound, reversing);

            if(nextIndex < targetIndex){
                let startIndexInter = tempArr[nextIndex];
                set tempArr w/= nextIndex <- -1;
                
                pebbleCFStep(
                    intermediateValuesNQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)] +
                    intermediateValuesNPad1[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                    ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)],
                    intermediateValuesDQ[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)] +
                    intermediateValuesNPad2[(tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1))..
                    ((tempArr[nextIndex - 1] / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)],
                    intermediateValuesAD1[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)], 
                    intermediateValuesAD2[tempArr[nextIndex - 1]..(tempArr[nextIndex - 1] + fixedBiggestSize - 1)], 
                    intermediateValuesNQ[startIndexInter..(startIndexInter + fixedBiggestSize - 1)] + 
                    intermediateValuesNPad1[(startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1))..
                    ((startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)],
                    intermediateValuesDQ[startIndexInter..(startIndexInter + fixedBiggestSize - 1)]+ 
                    intermediateValuesNPad2[(startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1))..
                    ((startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)],
                    intermediateValuesAD1[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    intermediateValuesAD2[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    intermediateValuesAuD[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    intermediateValuesAuM[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    intermediateValuesP[startIndexInter..(startIndexInter + fixedBiggestSize - 1)],
                    intermediateValuesP1[(startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1))..
                    ((startIndexInter / fixedBiggestSize * (fixedBiggestSize + 1)) + fixedBiggestSize)],
                    nextIndex - 1, true
                );
                
            }   

            set tempArr = unpebbleStep(currentIndex, maximumIndex - 1, targetIndex, tempArr, intermediateValuesNQ, 
                intermediateValuesDQ, intermediateValuesAD1, intermediateValuesAD2, intermediateValuesAuD, intermediateValuesAuM,
                intermediateValuesP, intermediateValuesNPad1, intermediateValuesNPad2, intermediateValuesP1, newNQ, newDQ, 
                newApproxDenom1, newApproxDenom2, newAuxDiv, newAuxMult, newPad, nPad1, nPad2, nP1,
                result, control, areTheSame, fixedBiggestSize, bound, reversing);  
        
        }

        return tempArr;
    }

}