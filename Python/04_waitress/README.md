# Python Compilation with PyInstaller

This is for educational and research purposes only. 

The GitLab CI/CD portion has a bash script that calls pyinstaller to compile a Python application. Documentation is available at [https://pyinstaller.org/en/stable/](https://pyinstaller.org/en/stable/).

First, switch to the Python application directory.

```
echo "cd PythonHelloWorld directory"
cd ${BASE_DIR}/PythonHelloWorld
```

Then call pyinstaller.

This commands tells PyInstaller to construct an executable from the app.py file.

The executable should be a single file and named "python_hello_world".

The executable should use all the package components for flask and waitress.

Flask lets Python applications act as a GUI application.

Waitress lets Python act as a web application with bundled web server. As a reminder, do not use the development web app/server embeded in the Python development environment, as it is not suited for any sort of real-world use.

```
echo "build PythonHelloWorld"
pyinstaller ./app.py --onefile --noconfirm --name python_hello_world --collect-all flask --collect-all waitress
```

The python_hello_world file is placed in the dist directory.

```
echo "list PythonHelloWorld target files"
ls -l ${BASE_DIR}/PythonHelloWorld/dist/*
```

The executable is called like any other.

The argument --bind can be used to specify the port used by the application, as shown below.
The --applogfile file collects output logs from the application being run by waitress.
The --accesslog file collects output logs from the web server access from waitress.
Below also collects the output from startup into a ${RES_BSH} file, to allow debugging and monitoring of the application startup (before app and Waitress logging starts).

```
nohup ./python_hello_world --bind *:${RES_PORT} --applogfile ${RES_LOG} --accesslog ${RES_GUN} >> ${RES_BSH} 2>&1 &
```

