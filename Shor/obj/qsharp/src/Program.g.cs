//------------------------------------------------------------------------------
// <auto-generated>                                                             
//     This code was generated by a tool.                                       
//     Changes to this file may cause incorrect behavior and will be lost if    
//     the code is regenerated.                                                 
// </auto-generated>                                                            
//------------------------------------------------------------------------------
#pragma warning disable 436
#pragma warning disable 162
#pragma warning disable 1591
using System;
using Microsoft.Quantum.Core;
using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.Core;

[assembly: CallableDeclaration("{\"Kind\":{\"Case\":\"Operation\"},\"QualifiedName\":{\"Namespace\":\"Shor.Testing\",\"Name\":\"testShorQubitCount\"},\"Attributes\":[],\"Modifiers\":{\"Access\":{\"Case\":\"DefaultAccess\"}},\"SourceFile\":\"C:\\\\Users\\\\andre\\\\OneDrive - University of Bath\\\\Anu3\\\\QuantumDissertationCode\\\\MyCode\\\\Shor\\\\Program.qs\",\"Position\":{\"Item1\":20,\"Item2\":4},\"SymbolRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":29}},\"ArgumentTuple\":{\"Case\":\"QsTuple\",\"Fields\":[[{\"Case\":\"QsTupleItem\",\"Fields\":[{\"VariableName\":{\"Case\":\"ValidName\",\"Fields\":[\"registerSize\"]},\"Type\":{\"Case\":\"Int\"},\"InferredInformation\":{\"IsMutable\":false,\"HasLocalQuantumDependency\":false},\"Position\":{\"Case\":\"Null\"},\"Range\":{\"Item1\":{\"Line\":1,\"Column\":30},\"Item2\":{\"Line\":1,\"Column\":42}}}]}]]},\"Signature\":{\"TypeParameters\":[],\"ArgumentType\":{\"Case\":\"Int\"},\"ReturnType\":{\"Case\":\"UnitType\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}}},\"Documentation\":[]}")]
[assembly: SpecializationDeclaration("{\"Kind\":{\"Case\":\"QsBody\"},\"TypeArguments\":{\"Case\":\"Null\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}},\"Parent\":{\"Namespace\":\"Shor.Testing\",\"Name\":\"testShorQubitCount\"},\"Attributes\":[],\"SourceFile\":\"C:\\\\Users\\\\andre\\\\OneDrive - University of Bath\\\\Anu3\\\\QuantumDissertationCode\\\\MyCode\\\\Shor\\\\Program.qs\",\"Position\":{\"Item1\":20,\"Item2\":4},\"HeaderRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":29}},\"Documentation\":[]}")]
[assembly: CallableDeclaration("{\"Kind\":{\"Case\":\"Operation\"},\"QualifiedName\":{\"Namespace\":\"Shor.Testing\",\"Name\":\"QuantumShor\"},\"Attributes\":[],\"Modifiers\":{\"Access\":{\"Case\":\"DefaultAccess\"}},\"SourceFile\":\"C:\\\\Users\\\\andre\\\\OneDrive - University of Bath\\\\Anu3\\\\QuantumDissertationCode\\\\MyCode\\\\Shor\\\\Program.qs\",\"Position\":{\"Item1\":37,\"Item2\":4},\"SymbolRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":22}},\"ArgumentTuple\":{\"Case\":\"QsTuple\",\"Fields\":[[{\"Case\":\"QsTupleItem\",\"Fields\":[{\"VariableName\":{\"Case\":\"ValidName\",\"Fields\":[\"NQ\"]},\"Type\":{\"Case\":\"ArrayType\",\"Fields\":[{\"Case\":\"Qubit\"}]},\"InferredInformation\":{\"IsMutable\":false,\"HasLocalQuantumDependency\":false},\"Position\":{\"Case\":\"Null\"},\"Range\":{\"Item1\":{\"Line\":1,\"Column\":23},\"Item2\":{\"Line\":1,\"Column\":25}}}]},{\"Case\":\"QsTupleItem\",\"Fields\":[{\"VariableName\":{\"Case\":\"ValidName\",\"Fields\":[\"result\"]},\"Type\":{\"Case\":\"ArrayType\",\"Fields\":[{\"Case\":\"Qubit\"}]},\"InferredInformation\":{\"IsMutable\":false,\"HasLocalQuantumDependency\":false},\"Position\":{\"Case\":\"Null\"},\"Range\":{\"Item1\":{\"Line\":1,\"Column\":36},\"Item2\":{\"Line\":1,\"Column\":42}}}]},{\"Case\":\"QsTupleItem\",\"Fields\":[{\"VariableName\":{\"Case\":\"ValidName\",\"Fields\":[\"r\"]},\"Type\":{\"Case\":\"Int\"},\"InferredInformation\":{\"IsMutable\":false,\"HasLocalQuantumDependency\":false},\"Position\":{\"Case\":\"Null\"},\"Range\":{\"Item1\":{\"Line\":1,\"Column\":53},\"Item2\":{\"Line\":1,\"Column\":54}}}]},{\"Case\":\"QsTupleItem\",\"Fields\":[{\"VariableName\":{\"Case\":\"ValidName\",\"Fields\":[\"adj\"]},\"Type\":{\"Case\":\"Bool\"},\"InferredInformation\":{\"IsMutable\":false,\"HasLocalQuantumDependency\":false},\"Position\":{\"Case\":\"Null\"},\"Range\":{\"Item1\":{\"Line\":1,\"Column\":61},\"Item2\":{\"Line\":1,\"Column\":64}}}]}]]},\"Signature\":{\"TypeParameters\":[],\"ArgumentType\":{\"Case\":\"TupleType\",\"Fields\":[[{\"Case\":\"ArrayType\",\"Fields\":[{\"Case\":\"Qubit\"}]},{\"Case\":\"ArrayType\",\"Fields\":[{\"Case\":\"Qubit\"}]},{\"Case\":\"Int\"},{\"Case\":\"Bool\"}]]},\"ReturnType\":{\"Case\":\"UnitType\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}}},\"Documentation\":[]}")]
[assembly: SpecializationDeclaration("{\"Kind\":{\"Case\":\"QsBody\"},\"TypeArguments\":{\"Case\":\"Null\"},\"Information\":{\"Characteristics\":{\"Case\":\"EmptySet\"},\"InferredInformation\":{\"IsSelfAdjoint\":false,\"IsIntrinsic\":false}},\"Parent\":{\"Namespace\":\"Shor.Testing\",\"Name\":\"QuantumShor\"},\"Attributes\":[],\"SourceFile\":\"C:\\\\Users\\\\andre\\\\OneDrive - University of Bath\\\\Anu3\\\\QuantumDissertationCode\\\\MyCode\\\\Shor\\\\Program.qs\",\"Position\":{\"Item1\":37,\"Item2\":4},\"HeaderRange\":{\"Item1\":{\"Line\":1,\"Column\":11},\"Item2\":{\"Line\":1,\"Column\":22}},\"Documentation\":[]}")]
#line hidden
namespace Shor.Testing
{
    [SourceLocation("C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs", OperationFunctor.Body, 21, 38)]
    public partial class testShorQubitCount : Operation<Int64, QVoid>, ICallable
    {
        public testShorQubitCount(IOperationFactory m) : base(m)
        {
        }

        String ICallable.Name => "testShorQubitCount";
        String ICallable.FullName => "Shor.Testing.testShorQubitCount";
        protected Allocate Allocate__
        {
            get;
            set;
        }

        protected Release Release__
        {
            get;
            set;
        }

        protected ICallable Microsoft__Quantum__Canon__ApplyToEach
        {
            get;
            set;
        }

        protected IUnitary<Qubit> Microsoft__Quantum__Intrinsic__H
        {
            get;
            set;
        }

        protected ICallable<(Int64,Int64), Int64> Microsoft__Quantum__Random__DrawRandomInt
        {
            get;
            set;
        }

        protected ICallable<(Int64,Int64), Int64> Microsoft__Quantum__Math__PowI
        {
            get;
            set;
        }

        protected ICallable Length__
        {
            get;
            set;
        }

        protected ICallable<(IQArray<Qubit>,IQArray<Qubit>,Int64,Boolean), QVoid> QuantumShor__
        {
            get;
            set;
        }

        public override Func<Int64, QVoid> __Body__ => (__in__) =>
        {
            var registerSize = __in__;
#line hidden
            {
#line 23 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                var NQ = Allocate__.Apply(registerSize);
#line hidden
                bool __arg1__ = true;
                try
                {
#line hidden
                    {
#line 24 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                        var result = Allocate__.Apply(registerSize);
#line hidden
                        bool __arg2__ = true;
                        try
                        {
#line 26 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                            Microsoft__Quantum__Canon__ApplyToEach.Apply((Microsoft__Quantum__Intrinsic__H, NQ));
#line 28 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                            var r = Microsoft__Quantum__Random__DrawRandomInt.Apply((1L, (Microsoft__Quantum__Math__PowI.Apply((2L, NQ.Length)) - 2L)));
#line 30 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                            QuantumShor__.Apply((NQ, result, r, false));
#line 31 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                            QuantumShor__.Apply((NQ, result, r, true));
#line 33 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                            Microsoft__Quantum__Canon__ApplyToEach.Apply((Microsoft__Quantum__Intrinsic__H, NQ));
                        }
#line hidden
                        catch
                        {
                            __arg2__ = false;
                            throw;
                        }
#line hidden
                        finally
                        {
                            if (__arg2__)
                            {
#line hidden
                                Release__.Apply(result);
                            }
                        }
                    }
                }
#line hidden
                catch
                {
                    __arg1__ = false;
                    throw;
                }
#line hidden
                finally
                {
                    if (__arg1__)
                    {
#line hidden
                        Release__.Apply(NQ);
                    }
                }
            }

#line hidden
            return QVoid.Instance;
        }

        ;
        public override void __Init__()
        {
            this.Allocate__ = this.__Factory__.Get<Allocate>(typeof(global::Microsoft.Quantum.Intrinsic.Allocate));
            this.Release__ = this.__Factory__.Get<Release>(typeof(global::Microsoft.Quantum.Intrinsic.Release));
            this.Microsoft__Quantum__Canon__ApplyToEach = this.__Factory__.Get<ICallable>(typeof(global::Microsoft.Quantum.Canon.ApplyToEach<>));
            this.Microsoft__Quantum__Intrinsic__H = this.__Factory__.Get<IUnitary<Qubit>>(typeof(global::Microsoft.Quantum.Intrinsic.H));
            this.Microsoft__Quantum__Random__DrawRandomInt = this.__Factory__.Get<ICallable<(Int64,Int64), Int64>>(typeof(global::Microsoft.Quantum.Random.DrawRandomInt));
            this.Microsoft__Quantum__Math__PowI = this.__Factory__.Get<ICallable<(Int64,Int64), Int64>>(typeof(global::Microsoft.Quantum.Math.PowI));
            this.Length__ = this.__Factory__.Get<ICallable>(typeof(global::Microsoft.Quantum.Core.Length<>));
            this.QuantumShor__ = this.__Factory__.Get<ICallable<(IQArray<Qubit>,IQArray<Qubit>,Int64,Boolean), QVoid>>(typeof(QuantumShor));
        }

        public override IApplyData __DataIn__(Int64 data) => new QTuple<Int64>(data);
        public override IApplyData __DataOut__(QVoid data) => data;
        public static System.Threading.Tasks.Task<QVoid> Run(IOperationFactory __m__, Int64 registerSize)
        {
            return __m__.Run<testShorQubitCount, Int64, QVoid>(registerSize);
        }
    }

    [SourceLocation("C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs", OperationFunctor.Body, 38, -1)]
    public partial class QuantumShor : Operation<(IQArray<Qubit>,IQArray<Qubit>,Int64,Boolean), QVoid>, ICallable
    {
        public QuantumShor(IOperationFactory m) : base(m)
        {
        }

        public class In : QTuple<(IQArray<Qubit>,IQArray<Qubit>,Int64,Boolean)>, IApplyData
        {
            public In((IQArray<Qubit>,IQArray<Qubit>,Int64,Boolean) data) : base(data)
            {
            }

            System.Collections.Generic.IEnumerable<Qubit> IApplyData.Qubits
            {
                get
                {
                    return Qubit.Concat(((IApplyData)Data.Item1)?.Qubits, ((IApplyData)Data.Item2)?.Qubits);
                }
            }
        }

        String ICallable.Name => "QuantumShor";
        String ICallable.FullName => "Shor.Testing.QuantumShor";
        protected Allocate Allocate__
        {
            get;
            set;
        }

        protected Release Release__
        {
            get;
            set;
        }

        protected ICallable Length__
        {
            get;
            set;
        }

        protected IUnitary<(IQArray<Qubit>,Int64,IQArray<Qubit>,Int64)> GenerateX__Testing__generateX
        {
            get;
            set;
        }

        protected IAdjointable Microsoft__Quantum__Canon__ApplyToEachA
        {
            get;
            set;
        }

        protected IUnitary<Qubit> Microsoft__Quantum__Intrinsic__H
        {
            get;
            set;
        }

        protected ICallable<(IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,Boolean), QVoid> Exponentiation__Testing__Exponentiation
        {
            get;
            set;
        }

        protected IUnitary<Microsoft.Quantum.Arithmetic.BigEndian> Microsoft__Quantum__Canon__QFT
        {
            get;
            set;
        }

        protected ICallable<IQArray<Qubit>, Microsoft.Quantum.Arithmetic.BigEndian> Microsoft__Quantum__Arithmetic__BigEndian
        {
            get;
            set;
        }

        protected IUnitary<Qubit> Microsoft__Quantum__Intrinsic__X
        {
            get;
            set;
        }

        protected ICallable<(IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,Boolean), QVoid> ContinuedFraction__Testing__CF
        {
            get;
            set;
        }

        protected IUnitary<(Int64,Microsoft.Quantum.Arithmetic.LittleEndian)> Microsoft__Quantum__Arithmetic__IncrementByInteger
        {
            get;
            set;
        }

        protected ICallable<IQArray<Qubit>, Microsoft.Quantum.Arithmetic.LittleEndian> Microsoft__Quantum__Arithmetic__LittleEndian
        {
            get;
            set;
        }

        protected ICallable<(IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,Boolean), QVoid> GCD__Testing__GCD
        {
            get;
            set;
        }

        public override Func<(IQArray<Qubit>,IQArray<Qubit>,Int64,Boolean), QVoid> __Body__ => (__in__) =>
        {
            var (NQ,result,r,adj) = __in__;
#line hidden
            {
#line 40 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                var xQ = Allocate__.Apply(NQ.Length);
#line hidden
                bool __arg1__ = true;
                try
                {
#line 42 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                    GenerateX__Testing__generateX.Apply((NQ, r, xQ, NQ.Length));
#line hidden
                    {
#line 45 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                        var exponent = Allocate__.Apply(((2L * NQ.Length) + 1L));
#line hidden
                        bool __arg2__ = true;
                        try
                        {
#line 47 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                            Microsoft__Quantum__Canon__ApplyToEachA.Apply((Microsoft__Quantum__Intrinsic__H, exponent));
#line hidden
                            {
#line 49 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                var expoResult = Allocate__.Apply(NQ.Length);
#line hidden
                                bool __arg3__ = true;
                                try
                                {
#line 52 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                    Exponentiation__Testing__Exponentiation.Apply((xQ, exponent, NQ, expoResult, false));
#line 57 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                    Microsoft__Quantum__Canon__QFT.Adjoint.Apply(new Microsoft.Quantum.Arithmetic.BigEndian(exponent));
#line hidden
                                    {
#line 60 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                        var denom = Allocate__.Apply(((2L * NQ.Length) + 1L));
#line hidden
                                        bool __arg4__ = true;
                                        try
                                        {
#line 61 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                            foreach (var index in new QRange(0L, (denom.Length - 1L)))
#line hidden
                                            {
#line 62 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                Microsoft__Quantum__Intrinsic__X.Apply(denom[index]);
                                            }

#line hidden
                                            {
#line 65 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                var period = Allocate__.Apply(NQ.Length);
#line hidden
                                                bool __arg5__ = true;
                                                try
                                                {
#line 67 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                    ContinuedFraction__Testing__CF.Apply((exponent, denom, NQ, period, false));
#line 69 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                    Microsoft__Quantum__Intrinsic__X.Apply(period[0L]);
#line hidden
                                                    {
#line 71 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                        var potentialFactor = Allocate__.Apply(NQ.Length);
#line hidden
                                                        bool __arg6__ = true;
                                                        try
                                                        {
#line 74 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            Microsoft__Quantum__Arithmetic__IncrementByInteger.Apply((1L, new Microsoft.Quantum.Arithmetic.LittleEndian(potentialFactor)));
#line 75 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            Exponentiation__Testing__Exponentiation.Apply((xQ, period, NQ, potentialFactor, false));
#line 76 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            Microsoft__Quantum__Arithmetic__IncrementByInteger.Adjoint.Apply((1L, new Microsoft.Quantum.Arithmetic.LittleEndian(potentialFactor)));
#line 77 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            GCD__Testing__GCD.Apply((potentialFactor, NQ, result, adj));
#line 79 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            Exponentiation__Testing__Exponentiation.Apply((xQ, period, NQ, potentialFactor, true));
#line 81 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            Microsoft__Quantum__Intrinsic__X.Apply(period[0L]);
#line 83 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            ContinuedFraction__Testing__CF.Apply((exponent, denom, NQ, period, true));
#line 85 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            foreach (var index in new QRange(0L, (denom.Length - 1L)))
#line hidden
                                                            {
#line 86 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                                Microsoft__Quantum__Intrinsic__X.Apply(denom[index]);
                                                            }

#line 89 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            Microsoft__Quantum__Canon__QFT.Apply(new Microsoft.Quantum.Arithmetic.BigEndian(exponent));
#line 90 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            Exponentiation__Testing__Exponentiation.Apply((xQ, exponent, NQ, expoResult, true));
#line 92 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            Microsoft__Quantum__Canon__ApplyToEachA.Adjoint.Apply((Microsoft__Quantum__Intrinsic__H, exponent));
#line 94 "C:\\Users\\andre\\OneDrive - University of Bath\\Anu3\\QuantumDissertationCode\\MyCode\\Shor\\Program.qs"
                                                            GenerateX__Testing__generateX.Adjoint.Apply((NQ, r, xQ, NQ.Length));
                                                        }
#line hidden
                                                        catch
                                                        {
                                                            __arg6__ = false;
                                                            throw;
                                                        }
#line hidden
                                                        finally
                                                        {
                                                            if (__arg6__)
                                                            {
#line hidden
                                                                Release__.Apply(potentialFactor);
                                                            }
                                                        }
                                                    }
                                                }
#line hidden
                                                catch
                                                {
                                                    __arg5__ = false;
                                                    throw;
                                                }
#line hidden
                                                finally
                                                {
                                                    if (__arg5__)
                                                    {
#line hidden
                                                        Release__.Apply(period);
                                                    }
                                                }
                                            }
                                        }
#line hidden
                                        catch
                                        {
                                            __arg4__ = false;
                                            throw;
                                        }
#line hidden
                                        finally
                                        {
                                            if (__arg4__)
                                            {
#line hidden
                                                Release__.Apply(denom);
                                            }
                                        }
                                    }
                                }
#line hidden
                                catch
                                {
                                    __arg3__ = false;
                                    throw;
                                }
#line hidden
                                finally
                                {
                                    if (__arg3__)
                                    {
#line hidden
                                        Release__.Apply(expoResult);
                                    }
                                }
                            }
                        }
#line hidden
                        catch
                        {
                            __arg2__ = false;
                            throw;
                        }
#line hidden
                        finally
                        {
                            if (__arg2__)
                            {
#line hidden
                                Release__.Apply(exponent);
                            }
                        }
                    }
                }
#line hidden
                catch
                {
                    __arg1__ = false;
                    throw;
                }
#line hidden
                finally
                {
                    if (__arg1__)
                    {
#line hidden
                        Release__.Apply(xQ);
                    }
                }
            }

#line hidden
            return QVoid.Instance;
        }

        ;
        public override void __Init__()
        {
            this.Allocate__ = this.__Factory__.Get<Allocate>(typeof(global::Microsoft.Quantum.Intrinsic.Allocate));
            this.Release__ = this.__Factory__.Get<Release>(typeof(global::Microsoft.Quantum.Intrinsic.Release));
            this.Length__ = this.__Factory__.Get<ICallable>(typeof(global::Microsoft.Quantum.Core.Length<>));
            this.GenerateX__Testing__generateX = this.__Factory__.Get<IUnitary<(IQArray<Qubit>,Int64,IQArray<Qubit>,Int64)>>(typeof(global::GenerateX.Testing.generateX));
            this.Microsoft__Quantum__Canon__ApplyToEachA = this.__Factory__.Get<IAdjointable>(typeof(global::Microsoft.Quantum.Canon.ApplyToEachA<>));
            this.Microsoft__Quantum__Intrinsic__H = this.__Factory__.Get<IUnitary<Qubit>>(typeof(global::Microsoft.Quantum.Intrinsic.H));
            this.Exponentiation__Testing__Exponentiation = this.__Factory__.Get<ICallable<(IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,Boolean), QVoid>>(typeof(global::Exponentiation.Testing.Exponentiation));
            this.Microsoft__Quantum__Canon__QFT = this.__Factory__.Get<IUnitary<Microsoft.Quantum.Arithmetic.BigEndian>>(typeof(global::Microsoft.Quantum.Canon.QFT));
            this.Microsoft__Quantum__Arithmetic__BigEndian = this.__Factory__.Get<ICallable<IQArray<Qubit>, Microsoft.Quantum.Arithmetic.BigEndian>>(typeof(global::Microsoft.Quantum.Arithmetic.BigEndian));
            this.Microsoft__Quantum__Intrinsic__X = this.__Factory__.Get<IUnitary<Qubit>>(typeof(global::Microsoft.Quantum.Intrinsic.X));
            this.ContinuedFraction__Testing__CF = this.__Factory__.Get<ICallable<(IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,Boolean), QVoid>>(typeof(global::ContinuedFraction.Testing.CF));
            this.Microsoft__Quantum__Arithmetic__IncrementByInteger = this.__Factory__.Get<IUnitary<(Int64,Microsoft.Quantum.Arithmetic.LittleEndian)>>(typeof(global::Microsoft.Quantum.Arithmetic.IncrementByInteger));
            this.Microsoft__Quantum__Arithmetic__LittleEndian = this.__Factory__.Get<ICallable<IQArray<Qubit>, Microsoft.Quantum.Arithmetic.LittleEndian>>(typeof(global::Microsoft.Quantum.Arithmetic.LittleEndian));
            this.GCD__Testing__GCD = this.__Factory__.Get<ICallable<(IQArray<Qubit>,IQArray<Qubit>,IQArray<Qubit>,Boolean), QVoid>>(typeof(global::GCD.Testing.GCD));
        }

        public override IApplyData __DataIn__((IQArray<Qubit>,IQArray<Qubit>,Int64,Boolean) data) => new In(data);
        public override IApplyData __DataOut__(QVoid data) => data;
        public static System.Threading.Tasks.Task<QVoid> Run(IOperationFactory __m__, IQArray<Qubit> NQ, IQArray<Qubit> result, Int64 r, Boolean adj)
        {
            return __m__.Run<QuantumShor, (IQArray<Qubit>,IQArray<Qubit>,Int64,Boolean), QVoid>((NQ, result, r, adj));
        }
    }
}