using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Simulators;

namespace ContinuedFraction.Testing
{
    class Driver
    {
        static void Main(string[] args)
        {
            var sim = new ToffoliSimulator();
            Random rand = new Random();
            var bad = 0;
            for(int i = 0; i < 100; i++){

              var bound = new BigInteger(rand.Next(100000));
              var r = new BigInteger(rand.Next((int)(ulong)bound));
              while(IsPrime((int)r) == false){
                r = new BigInteger(rand.Next((int)(ulong)bound));
              }
              //num = 2;
              //bound = 7;
              
              // to properly test this
              // choose a value for the bound, then a random value r from 0 to bound - 1
              // then choose the denom to be 2^(2*log(bound) + 1)
              // find random value t from 0 to previous r - 1
              // compute integer t / r * denom
              // approximate fraction integer / denom
              // see if the value is the same as r

              var denom = new BigInteger(Math.Pow(2.0, 2 * Math.Ceiling(Math.Log2((double) bound))));
              var t = new BigInteger(rand.Next((int)(ulong)r));
              var num = new BigInteger(Math.Floor((double)t * (double)denom / (double)r));
              
              if(num > denom) {
                var temp = denom;
                denom = num;
                num = temp;
              }
              
              // num = 54821;
              // denom = 295847;
              // bound = 2575;
              // //denom = 10;

              // num = 13643376;
              // denom = 16777216;
              // bound = 3946;
              // r = 3528;

              Console.WriteLine("Initial values are {0}/{1} in bound {2} and r is {3}", num, denom, bound, r);
              var result = testCF.Run(sim, num, denom, bound).Result;
              if(result != r && r % result != 0){
                bad += 1;
              }
              Console.WriteLine("The quantum convergent fraction denominator is {0}", result);  
              Console.WriteLine("Accuracy {0}/{1}\n", (i + 1 - bad), i + 1);
            }
            Console.WriteLine("Overall accuracy {0}/100", (100 - bad));

            ResourcesEstimator estimator = new ResourcesEstimator();
            int RegisterSize = 10; 
            testCFQubitCount.Run(estimator,RegisterSize).Wait();
            //testGreaterCount.Run(estimator,RegisterSize).Wait();
            
            Console.WriteLine(estimator.ToTSV());
        }

        public static bool IsPrime(int number)
        {
          if (number <= 1) return false;
          if (number == 2) return true;
          if (number % 2 == 0) return false;

          var boundary = (int)Math.Floor(Math.Sqrt(number));
                
          for (int i = 3; i <= boundary; i += 2)
              if (number % i == 0)
                  return false;
          
          return true;        
        }

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

        public static int Size(BigInteger bits) {
          int size = 0;

          for (; bits != 0; bits >>= 1)
            size++;

          return size;
        }

        public static int SizeR(int bits) {
          int size = 0;

          for (; bits != 0; bits >>= 1)
            size++;

          return size;
        }

    }
}

