#include "kittens.cuh"
#include "pyutils/pyutils.cuh"
using namespace kittens;

using my_layout = gl<float, -1, -1, -1, 64, st_fl<64, 64>>;  // An example layout that also instantiates a TMA descriptor on Hopper.
struct globals {
    my_layout in, out;
    dim3 grid() { return dim3(in.batch(), in.depth(), in.rows()); }
    dim3 block() { return dim3(in.cols()); }
};
__global__ void copy_kernel(const __grid_constant__ globals g) {
    if (threadIdx.x == 0 && blockIdx.x == 0 &&
        blockIdx.y == 0 && blockIdx.z == 0)
        printf("Hello, from inside the kernel!\n");

    // Cast CUDA built-ins to avoid narrowing warnings
    const int bx = static_cast<int>(blockIdx.x);
    const int by = static_cast<int>(blockIdx.y);
    const int bz = static_cast<int>(blockIdx.z);
    const int tx = static_cast<int>(threadIdx.x);

    g.out[{bx, by, bz, tx}] = g.in[{bx, by, bz, tx}];
}
void run_copy_kernel(globals g) {
    printf("I am calling the kernel from the host.\n");
    copy_kernel<<<g.grid(), g.block()>>>(g);
}

PYBIND11_MODULE(example_bind, m) {
    m.doc() = "example_bind python module";
    py::bind_kernel<copy_kernel>(m, "copy_kernel", &globals::in, &globals::out);
    py::bind_function<run_copy_kernel>(m, "wrapped_copy_kernel", &globals::in, &globals::out);
}
