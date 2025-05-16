# module/test.py

import time
import traceback
from typing import Any, Callable, Tuple, Optional

# ANSI escape codes for colors
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

_test_counter = 0
_passed_counter = 0
_total_time = 0.0

def run(
    func_to_test: Callable,
    args: Tuple,
    expected_output: Any,
    test_name: Optional[str] = None,
    precision: Optional[int] = None # For floating point comparisons
):
    """
    Runs a single test case.

    Args:
        func_to_test: The function or method to be tested.
        args: A tuple of arguments to pass to the function.
              For methods of a class, the instance method should be passed
              (e.g., sol.my_method), and `args` will be the arguments
              excluding `self`.
              For functions with a single argument, pass it as a tuple: (arg,).
        expected_output: The expected result from the function.
        test_name: An optional name for the test case.
        precision: Optional number of decimal places for float comparison.
    """
    global _test_counter, _passed_counter, _total_time
    _test_counter += 1

    current_test_name = f"Test #{_test_counter}"
    if test_name:
        current_test_name += f": {test_name}"

    print(f"{bcolors.HEADER}--- {current_test_name} ---{bcolors.ENDC}")
    
    # Displaying args can be tricky if they are very large.
    # For now, direct print. Could be truncated later if needed.
    # Ensure args is always a tuple for consistent unpacking
    if not isinstance(args, tuple):
        # This case should ideally not happen if used as intended (args=(arg1, arg2...))
        # but as a safeguard for single arguments not passed in a tuple.
        print(f"Input: {args}") # Single argument not in a tuple
    elif len(args) == 1:
        print(f"Input: {args[0]}") # Single argument in a tuple, print it bare
    else:
        print(f"Inputs: {args}")
    
    print(f"Expected: {expected_output}")

    start_time = time.perf_counter()
    try:
        actual_output = func_to_test(*args)
        end_time = time.perf_counter()
        duration = (end_time - start_time) * 1000  # milliseconds
        _total_time += duration
        print(f"Actual:   {actual_output}")
        print(f"Time:     {duration:.3f} ms")

        passed = False
        if precision is not None and isinstance(actual_output, float) and isinstance(expected_output, float):
            if abs(actual_output - expected_output) < (10 ** -precision):
                passed = True
        elif actual_output == expected_output:
            passed = True
        
        if passed:
            print(f"{bcolors.OKGREEN}PASS{bcolors.ENDC}\n")
            _passed_counter += 1
            return True
        else:
            print(f"{bcolors.FAIL}FAIL{bcolors.ENDC}")
            print(f"  Expected: {expected_output}")
            print(f"  Actual:   {actual_output}{bcolors.ENDC}\n")
            return False

    except Exception as e:
        end_time = time.perf_counter()
        duration = (end_time - start_time) * 1000
        _total_time += duration
        print(f"{bcolors.FAIL}ERROR during execution: {e}{bcolors.ENDC}")
        print(f"Time until error: {duration:.3f} ms")
        print(f"{bcolors.WARNING}Traceback:{bcolors.ENDC}")
        traceback.print_exc()
        print("") # Newline after traceback
        return False

def summary():
    """Prints a summary of all test runs."""
    global _test_counter, _passed_counter, _total_time
    print(f"\n{bcolors.BOLD}========== TEST SUMMARY =========={bcolors.ENDC}")
    if _test_counter == 0:
        print("No tests were run.")
        return

    color = bcolors.OKGREEN if _passed_counter == _test_counter else bcolors.FAIL
    print(f"{color}Passed {_passed_counter}/{_test_counter} tests.{bcolors.ENDC}")
    print(f"Total execution time for tested functions: {_total_time:.3f} ms")
    avg_time = _total_time / _test_counter if _test_counter > 0 else 0
    print(f"Average time per test function call: {avg_time:.3f} ms")
    print(f"{bcolors.BOLD}================================{bcolors.ENDC}\n")

def reset():
    """Resets test counters and total time. Useful if running multiple suites in one script."""
    global _test_counter, _passed_counter, _total_time
    _test_counter = 0
    _passed_counter = 0
    _total_time = 0.0
    print(f"{bcolors.OKBLUE}Test counters have been reset.{bcolors.ENDC}")

# You could also create a TestRunner class if you prefer an object-oriented approach,
# which would encapsulate the counters and summary logic.
# For simplicity, global functions are often sufficient for this use case.
