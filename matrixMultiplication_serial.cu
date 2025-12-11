#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <iomanip>
#include <chrono>

using namespace std;

int main()
{
    int m, k, k2, n;

    cout << "Enter rows and columns of matrix A (m k): ";
    cin >> m >> k;

    cout << "Enter rows and columns of matrix B (k2 n): ";
    cin >> k2 >> n;

    vector<double> A(m * k);
    vector<double> B(k * n);
    vector<double> C(m * n);

    srand((unsigned)time(nullptr));

    for (int i = 0; i < m * k; i++)
    {
        A[i] = rand() % 10;
    }

    for (int i = 0; i < k * n; i++)
    {
        B[i] = rand() % 10;
    }

  

    auto start = chrono::high_resolution_clock::now();

    for (int row = 0; row < m; row++)
    {
        for (int col = 0; col < n; col++)
        {
            double sum = 0.0;
            for (int t = 0; t < k; t++)
            {
                sum += A[row * k + t] * B[t * n + col];
            }
            C[row * n + col] = sum;
        }
    }

    auto end = chrono::high_resolution_clock::now();
    chrono::duration<double, milli> duration = end - start;

    cout << "\nSerial multiplication took " << duration.count() << " ms" << endl;

    return 0;
}


