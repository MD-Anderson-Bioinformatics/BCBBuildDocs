/*
Copyright (c) 2023-2024 University of Texas MD Anderson Cancer Center

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

MD Anderson Cancer Center Bioinformatics on GitHub <https://github.com/MD-Anderson-Bioinformatics>
MD Anderson Cancer Center Bioinformatics at MDA <https://www.mdanderson.org/research/departments-labs-institutes/departments-divisions/bioinformatics-and-computational-biology.html>
 */
package edu.bcb.javahelloworld;

import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author Tod_Casasent
 */
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
