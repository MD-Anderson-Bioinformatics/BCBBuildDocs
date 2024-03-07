# Python Unit Test

This is for educational and research purposes only. 

The GitLab CI/CD portion has a bash script that calls the unit test for the Python application.

First, switch to the Python application directory.

```
echo "cd PythonHelloWorld directory"
cd ${BASE_DIR}/PythonHelloWorld
```

Then call the unit test  with Python.

The -m unittest tells Python that a unit test is being performed.

test_world.TestHelloWorld tells it which test to perform. In this case the test_world.py file contains a unittest.TestCase class named TestHelloWorld.

```
echo "unittest PythonHelloWorld"
python -m unittest test_world.TestHelloWorld
```

The unittest class is a standard part of Python 3. Documentation is available at [https://docs.python.org/3/library/unittest.html](https://docs.python.org/3/library/unittest.html).

Our test file looks like the one shown below. This test is pretty worthless, but illustrates the concept of performing the unit test.

```
import unittest

import app


class TestHelloWorld(unittest.TestCase):

    def test_output(self):
        # this is a fairly useless test, but illustrates the concept
        self.assertEqual(app.hello_world(), 'Konnichi wa! Hello World!')


if __name__ == '__main__':
    unittest.main()
```

