#include <iostream>
#include <vector>
#include <limits>
#include <cstdlib>
#include <ctime>
#include <chrono>

using namespace std;

#define INF 1000000000

// serial Dijkstra
void dijkstraSerial(int n, const vector<int>& adj, vector<int>& dist)
{
    vector<bool> visited(n, false);

    dist.assign(n, INF);

    dist[0] = 0;

    for (int count = 0; count < n - 1; count++)
    {
        int u = -1;
        int minDist = INF;

        // find next vertex
        for (int i = 0; i < n; i++)
        {
            if (!visited[i] && dist[i] < minDist)
            {
                minDist = dist[i];
                u = i;
            }
        }

        if (u == -1)
        {
            break;
        }

        visited[u] = true;

        // relax edges
        for (int v = 0; v < n; v++)
        {
            int w = adj[u * n + v];

            if (!visited[v] && w > 0 && w < INF && dist[u] + w < dist[v])
            {
                dist[v] = dist[u] + w;
            }
        }
    }
}

int main()
{
    srand((unsigned int)time(NULL));

    int n;

    cout << "Enter number of vertices: ";
    cin >> n;

    // adjacency matrix
    vector<int> adj(n * n, INF);

    for (int i = 0; i < n; i++)
    {
        adj[i * n + i] = 0;
    }

    // random undirected graph
    for (int i = 0; i < n; i++)
    {
        for (int j = i + 1; j < n; j++)
        {
            int w = rand() % 20 + 1;

            adj[i * n + j] = w;
            adj[j * n + i] = w;
        }
    }

    vector<int> distSerial;

    // start timer
    auto t1 = chrono::high_resolution_clock::now();

    dijkstraSerial(n, adj, distSerial);

    // stop timer
    auto t2 = chrono::high_resolution_clock::now();

    double cpuTime = chrono::duration<double, milli>(t2 - t1).count();

    cout << "\n Serial Dijkstra Distances From Vertex 0\n";

    for (int i = 0; i < n; i++)
    {
        cout << "Vertex " << i << " : " << distSerial[i] << endl;
    }

    cout << "\nCPU Runtime: " << cpuTime << " ms\n";

    return 0;
}



