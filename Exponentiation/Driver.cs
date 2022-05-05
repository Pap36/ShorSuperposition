using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Simulators;

namespace Exponentiation.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {
            
            // TestOnToffoli();


            // ResourcesEstimator estimator = new ResourcesEstimator();
            // int RegisterSize = 10; 
            // testExpoQubitCount.Run(estimator,RegisterSize).Wait();
            // Console.WriteLine(estimator.ToTSV());

        }

        public static void TestOnToffoli(){
          var sim = new ToffoliSimulator();
          Random rand = new Random();
          int badCount = 0;
          for (int value = 0; value < 100; value++) {
            var a = new BigInteger(rand.Next());
            var b = new BigInteger(rand.Next());
            var c = new BigInteger(rand.Next());
            
            Console.WriteLine("Initial Values for a b c: {0} {1} {2}", a, b, c);
            
            var res = testExpo.Run(sim, a, b, c).Result;
            var curr = a;
            var bits = getBits(b);
            var expectedRes = new BigInteger(1);

            
            foreach (bool bit in bits){
              expectedRes = (curr * curr) % c;
              if(bit == true){
                expectedRes = (expectedRes * a) % c;
              }
              //Console.WriteLine("Values for bit curr expected: {0} {1} {2}", bit, curr, expectedRes);
              curr = expectedRes;
            }

            Console.WriteLine("Expected {0} and got {1}", expectedRes, res);
            if(expectedRes != res) {
              badCount += 1;
            }
            
            Console.WriteLine("Accuracy {0} / {1}", value + 1 - badCount, value + 1);

          }
          Console.WriteLine("Accuracy {0} / 100", 100 - badCount);
        }

        // nfunction returns the binary representation of a number and discounts
        // the most significant bit
        public static bool[] getBits(BigInteger b){
          bool[] bits = new bool[Size(b)];
          int count = 0;
          while(b > 0){
            BigInteger rem = 0;
            BigInteger.DivRem(b, 2, out rem);
            if((int)rem == 1){
              bits[count] = true;
            } else {
              bits[count] = false;
            }
            b = (b - rem) / 2;
            count += 1;
          }
          Array.Reverse(bits);
          return new ArraySegment<bool>(bits, 1, bits.Length - 1).ToArray();
        }

        // function returns the bit-length of a number
        public static int Size(BigInteger bits) {
          int size = 0;

          for (; bits != 0; bits >>= 1)
            size++;

          return size;
        }

    }
}

