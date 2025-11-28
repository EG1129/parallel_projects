#include <iostream>
#include <vector>
#include <limits>
#include <cstdlib>
#include <ctime>
#include <cuda_runtime.h>

using namespace std;

#define INF 1000000000

// GPU kernel to relax edges from vertex u
__global__ void relaxKernel(int u, int n, const int* adj, int* dist, const bool* visited)
{
    int v = blockIdx.x * blockDim.x + threadIdx.x;

    if (v < n && !visited[v])
    {
        int w = adj[u * n + v];

        if (w > 0 && w < INF)
        {
            int newDist = dist[u] + w;

            if (newDist < dist[v])
            {
                dist[v] = newDist;
            }
        }
    }
}

// CUDA Dijkstra (CPU finds next vertex, GPU relaxes edges)
void dijkstraCUDA(int n, const vector<int>& adj, vector<int>& dist, float& gpuTimeMs)
{
    vector<bool> visited(n, false);

    dist.assign(n, INF);

    dist[0] = 0;

    int* d_adj;
    int* d_dist;
    bool* d_visited;

    size_t adjSize = n * n * sizeof(int);
    size_t distSize = n * sizeof(int);
    size_t visitedSize = n * sizeof(bool);

    cudaMalloc((void**)&d_adj, adjSize);
    cudaMalloc((void**)&d_dist, distSize);
    cudaMalloc((void**)&d_visited, visitedSize);

    cudaMemcpy(d_adj, adj.data(), adjSize, cudaMemcpyHostToDevice);

    int blockSize = 256;
    int numBlocks = (n + blockSize - 1) / blockSize;

    // CUDA timers
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    for (int count = 0; count < n - 1; count++)
    {
        int u = -1;
        int minDist = INF;

        // CPU selects next vertex
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

        cudaMemcpy(d_dist, dist.data(), distSize, cudaMemcpyHostToDevice);
        cudaMemcpy(d_visited, visited.data(), visitedSize, cudaMemcpyHostToDevice);

        relaxKernel << <numBlocks, blockSize >> > (u, n, d_adj, d_dist, d_visited);

        cudaDeviceSynchronize();

        cudaMemcpy(dist.data(), d_dist, distSize, cudaMemcpyDeviceToHost);
    }

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&gpuTimeMs, start, stop);

    cudaFree(d_adj);
    cudaFree(d_dist);
    cudaFree(d_visited);
}

int main()
{
    srand((unsigned int)time(NULL));

    int n;

    cout << "Enter number of vertices: ";
    cin >> n;

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

    vector<int> distCUDA;

    float gpuTimeMs = 0.0f;

    dijkstraCUDA(n, adj, distCUDA, gpuTimeMs);

    cout << "\n--- CUDA Dijkstra Distances From Vertex 0 ---\n";

    for (int i = 0; i < n; i++)
    {
        cout << "Vertex " << i << " : " << distCUDA[i] << endl;
    }

    cout << "\nCUDA Runtime: " << gpuTimeMs << " ms\n";

    return 0;
}



