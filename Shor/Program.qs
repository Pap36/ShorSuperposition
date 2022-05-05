namespace Shor.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;    
    open Microsoft.Quantum.Logical;
    open Microsoft.Quantum.Random;
    open GenerateX.Testing;
    open Exponentiation.Testing;
    open ContinuedFraction.Testing;
    open GCD.Testing;

    // operation used to set up a superposition of values using the Hadamard gat
    // so that the operation can be checked when running in superposition
    // also provides a good estimate for the number of qubits required when running
    // the resource estimator
    operation testShorQubitCount(registerSize: Int): Unit{
        
        use NQ = Qubit[registerSize];
        use result = Qubit[registerSize];

        ApplyToEach(H, NQ);
        
        let r = DrawRandomInt(1, PowI(2,Length(NQ)) - 2);
        
        QuantumShor(NQ, result, r, false);
        QuantumShor(NQ, result, r, true);

        ApplyToEach(H, NQ);

    }
    
    
    operation QuantumShor(NQ: Qubit[], result: Qubit[], r: Int, adj: Bool) : Unit {
        // first, we need to generate x from N
        use xQ = Qubit[Length(NQ)];
        
        generateX(NQ, r, xQ, Length(NQ));
        
        // then we make a superposition of the states in another register on which we apply QTF?
        use exponent = Qubit[2 * Length(NQ) + 1];
        
        ApplyToEachA(H, exponent);

        use expoResult = Qubit[Length(NQ)];
        
        // remember that exponent needs to be converted and remove the most significant bit
        Exponentiation(xQ, exponent, NQ, expoResult, false);

        // now we have 
        // |N>|x>|j>|x^j % N>

        Adjoint QFT(BigEndian(exponent));
        
        // this supposedly puts everything else such that I can find R by applying CF on the exponent?
        use denom = Qubit[2* Length(NQ) + 1];
        for index in 0..Length(denom) - 1{
            X(denom[index]);
        }
        
        use period = Qubit[Length(NQ)];

        CF(exponent, denom, NQ, period, false);

        X(period[0]);
        // potential factor
        use potentialFactor = Qubit[Length(NQ)];
        // recall that mod exp is implemented so that result is in 
        // state |1>
        IncrementByInteger(1, LittleEndian(potentialFactor));
        Exponentiation(xQ, period, NQ, potentialFactor, false);
        Adjoint IncrementByInteger(1, LittleEndian(potentialFactor));
        GCD(potentialFactor, NQ, result, adj);

        Exponentiation(xQ, period, NQ, potentialFactor, true);
        
        X(period[0]);

        CF(exponent, denom, NQ, period, true);
        //Adjoint AddI(LittleEndian(NQ), LittleEndian(bound));
        for index in 0..Length(denom) - 1{
            X(denom[index]);
        }
        
        QFT(BigEndian(exponent));
        Exponentiation(xQ, exponent, NQ, expoResult, true);

        Adjoint ApplyToEachA(H, exponent);

        Adjoint generateX(NQ, r, xQ, Length(NQ));

    }
}
