# Python Unit Test

This is for educational and research purposes only. 

The GitLab CI/CD portion has a bash script that calls the unit test for the Java application.

First, switch to the Java application directory.

```
echo "compile JavaHelloWorld"
cd ${BASE_DIR}/JavaHelloWorld
```

Then compile the Java application and execute any JUnit tests in the application. This is done using mvn.

```
mvn clean install dependency:copy-dependencies
```

The WAR file, used to deploy the application in Tomcat, is in the JavaHelloWorld/target directory.

```
echo "list JavaHelloWorld target files"
ls -l ${BASE_DIR}/JavaHelloWorld/target/*.war
```

The Java JUnit test is in JavaHelloWorld/src/test/java/edu/bcb/javahelloworld/GetTextTest.java

Our test file looks like the one shown below. This test is pretty worthless, but illustrates the concept of performing the unit test.

```
package edu.bcb.javahelloworld;

import org.junit.Test;
import static org.junit.Assert.*;

public class GetTextTest
{
	
	public GetTextTest()
	{
	}
	
	/**
	 * Test of getHelloWorldText method, of class GetText.
	 */
	@Test
	public void testGetHelloWorldText()
	{
		System.out.println("getHelloWorldText");
		String expResult = "Hello World! Konnichi wa!";
		String result = GetText.getHelloWorldText();
		assertEquals(expResult, result);
	}

}
```

