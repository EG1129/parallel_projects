#include <mpi.h>
#include <iostream>
#include <string>
#include <chrono>

using namespace std;
bool generateCombinations(const string& characters, string current, int maxLength, string password, int rank, int& found_flag)
{
    //cout << "Trying: " << current << endl; //visualize recursion

    if (!current.empty() && current == password)
    {
        cout << "Password found by rank " << rank << ": " << current << endl;
        found_flag = 1;
        return true;
    }                   
    if (current.length() == maxLength)
    {
        return false;
    }

    for (char c : characters)
    {
        if (generateCombinations(characters, current + c, maxLength, password, rank, found_flag))
        {
            return true;
        }
    }
    return false;
}

int main(int argc, char* argv[])
{
    // MPI stuff
    MPI_Init(&argc, &argv);

    int rank;
    int size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    string characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    string target = "1234"; 
    int maxLength = 0;

    if (rank == 0)
    {
        cout << "enter password max length";
        cin >> maxLength;
        cout << "Running with " << size << " MPI processes.\n";
        cout << "Searching for: \"" << target << "\" up to length " << maxLength << endl;
    }

    // broadcast maxLength to all processes
    MPI_Bcast(&maxLength, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Barrier(MPI_COMM_WORLD); // synchronize before starting timer
    // measure runtime
    auto start = chrono::high_resolution_clock::now();

    int found_flag = 0;

	// each core will start with different first character, if password is found then break loop
    for (int i = rank; i < (int)characters.size(); i += size)
    {
        char firstChar = characters[i];
        string start(1, firstChar);   
        if (generateCombinations(characters, start, maxLength, target, rank, found_flag))
        {
            break; // stop when target is found
        }
    }

    // reduction to see if any rank found target
    int global_found = 0;
    MPI_Allreduce(&found_flag, &global_found, 1, MPI_INT, MPI_LOR, MPI_COMM_WORLD);

   // measure runtime
    auto end = std::chrono::high_resolution_clock::now();
    chrono::duration<double> elapsed = end - start;

    if (rank == 0)
    {
        if (!global_found) 
        {
            cout << "Password not found." << endl;
        }
        cout << "execution time: " << elapsed.count() << " seconds\n";
    }

    MPI_Finalize();
    return 0;
}
