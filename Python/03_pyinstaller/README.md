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

The executable should use all the package components for flask and waitress. (Flask lets Python applications act as a GUI application. Waitress lets Python act as a web application with bundled web server.)

```
echo "build PythonHelloWorld"
pyinstaller ./app.py --onefile --noconfirm --name python_hello_world --collect-all flask --collect-all waitress
```

The python_hello_world file is placed in the dist directory.

```
echo "list PythonHelloWorld target files"
ls -l ${BASE_DIR}/PythonHelloWorld/dist/*
```

