import parsl
import argparse
import os
import glob
from parsl import python_app
import pathlib
from polaris_multinode import config


@python_app(cache=True)
def minhash_file(infile: str, output_dir: str, num_perm: int) -> float:
    from deduplication.minhash import compute_minhash_for_file
    import time
    start = time.perf_counter()
    compute_minhash_for_file(infile, output_dir, num_perm)
    done = time.perf_counter()
    return infile, done-start


def minhash_dir(input_dir: str, output_dir: str, num_perm: int = 128):

    pathlib.Path(output_dir).mkdir(parents=True, exist_ok=True)
    futures = []
    for jsonl_file in glob.glob(input_dir + "/*json*"):
        print(f"Processing: {jsonl_file}")
        future = minhash_file(jsonl_file, output_dir, num_perm=128)
        futures.append(future)

    for fu in futures:
        infile, time = fu.result()
        print(f"Processed {infile} in {time:.2f}s")
    print("Done processing all files")

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--input_dir", required=True,
                        help="Input directory with jsonl files")
    parser.add_argument("--output_dir", required=True,
                        help="Output directory to write pickle output files")
    parser.add_argument("--num_perm", required=True,
                        help="Number of permutations in the minhash calculation")
    args = parser.parse_args()

    parsl.load(config)
    minhash_dir(args.input_dir, args.output_dir, args.num_perm)
    
