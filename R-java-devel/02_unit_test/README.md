# R Unit Test

This is for educational and research purposes only. 

The GitLab CI/CD portion has a bash script that calls the unit tests for the R application.

First, switch to the R application directory.

```
echo "cd RHelloWorld directory"
cd ${BASE_DIR}/RHelloWorld
```

Then build the package - R runs the "check" command on a tar.gz package compilation.

```
R CMD build RHelloWorld
```

Then call the "check" command with R - which does tests and vignettes. Vignettes are great for testing, since they can double as reproducible example code. Note as previously mentioned, the check runs on the compiled version of the package.

```
echo "unittest RHelloWorld"
R CMD check RHelloWorld_*.tar.gz
```

If you then desire to install this package, you can do so using the following code.

```
echo "Install RHelloWorld"
R CMD INSTALL RHelloWorld_*.tar.gz
```

