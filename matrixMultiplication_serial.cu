#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <iomanip>
#include <chrono>

using namespace std;

int main()
{
    int r, c;      // Matrix A dimensions: r x c
    int r1, c1;    // Matrix B dimensions: r1 x c1

    // Input for matrix A
    cout << "Enter rows and columns of matrix A (r c): ";
    cin >> r >> c;

    // Input for matrix B
    cout << "Enter rows and columns of matrix B (r1 c1): ";
    cin >> r1 >> c1;

    // A is r x c
    // B is r1 x c1 — must satisfy c == r1 for multiplication
    if (c != r1)
    {
        cout << "Error: Cannot multiply matrices. Columns of A must equal rows of B." << endl;
        return 0;
    }

    // Allocate matrices
    vector<double> A(r * c);        // A[r][c]
    vector<double> B(r1 * c1);      // B[r1][c1]
    vector<double> C(r * c1);       // C[r][c1]

    srand((unsigned)time(nullptr));

    // Fill A with random values
    for (int i = 0; i < r * c; i++)
    {
        A[i] = rand() % 10;
    }

    // Fill B with random values
    for (int i = 0; i < r1 * c1; i++)
    {
        B[i] = rand() % 10;
    }

    auto start = chrono::high_resolution_clock::now();

    // SERIAL MATRIX MULTIPLICATION
    for (int i = 0; i < r; i++)          // row of A (& C)
    {
        for (int j = 0; j < c1; j++)     // column of B (& C)
        {
            double sum = 0.0;

            for (int t = 0; t < c; t++)  // shared dimension: A's c and B's r1
            {
                int A_index = i * c + t;      // A[i][t]
                int B_index = t * c1 + j;     // B[t][j]
                sum += A[A_index] * B[B_index];
            }

            C[i * c1 + j] = sum;              // C[i][j]
        }
    }

    auto end = chrono::high_resolution_clock::now();
    chrono::duration<double, milli> duration = end - start;

    cout << "\nSerial multiplication took " << duration.count() << " ms" << endl;

    return 0;
}



