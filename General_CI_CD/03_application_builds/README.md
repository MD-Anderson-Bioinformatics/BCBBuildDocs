# GitLab CI/CD Application builds

This is for educational and research purposes only. 

This contains an overview of building and testing Python and Java applications as part of the CI/CD process.

# GitLab CI YML

Within the "script" portion of the compile_and_test_job in the gitlab-ci.yml file, the build_apps.bash function is called. This script builds, compiles, and performed unit tests.

Reminder, this job runs within a Docker container built and maintained for building these applications.

# Build and Unit Test Script: Java

The build apps script switches to the JavaHelloWorld directory and uses Maven to build and test the Java App. The command uses the clean, install, and copy-dependecies arguments. JUnit tests are done automatically. If a JUnit test fails, the mvn command returns with an error, stopping the build process.

```
echo "compile JavaHelloWorld"
cd ${BASE_DIR}/JavaHelloWorld
mvn clean install dependency:copy-dependencies
```

Looking at the build_copy.bash script, you can see how the WAR built from that command is copied to the folder from which GitLab builds a CI/CD archive file. We use this archive directory and the files in it in the Docker image build step.

For JavaHelloWorld, being a Java web app, we just need the WAR file.

```
echo "copy JavaHelloWorld"
cp ${BASE_DIR}/JavaHelloWorld/target/*.war ${DEST_DIR}/JavaHelloWorld.war
```

# Build and Unit Test Script: Python

The build apps script switches to the PythonHelloWorld directory and uses Python 3 to build and test the Python App. The command uses the "-m unittest" options to unit test the Python application. A failure in the Python tests will cause the command line to return an error, halting the build.

```
echo "cd PythonHelloWorld directory"
cd ${BASE_DIR}/PythonHelloWorld

echo "unittest PythonHelloWorld"
python -m unittest test_world.TestHelloWorld
```

Then we use pyinstaller to create a single-file Python executable for our application. Keywords uses include compiling into --onefile, using --noconfirm since it is not in an interactive session, naming the output file and making sure the flask and waitress libraries are included in the compilation.

```
echo "build PythonHelloWorld"
pyinstaller ./app.py --onefile --noconfirm --name python_hello_world --collect-all flask --collect-all waitress
```

Looking at the build_copy.bash script, you can see how the extension-less executable built from that command is copied to the folder from which GitLab builds a CI/CD archive file. We use this archive directory and the files in it in the Docker image build step.

```
echo "copy Python python_hello_world"
cp ${BASE_DIR}/PythonHelloWorld/dist/python_hello_world ${DEST_DIR}/.
```

