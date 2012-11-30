/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package featureExtractor;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.StringTokenizer;

/**
 *
 * @author Ilan
 */
public class FeatureExtractor {
	/*
	 * Features:
	 * Number of comments
	 * Number of lines
	 * Coding style with spacing in if conditon, while and for loops
	 * Number of condition statements
	 * Number of while loops
	 * Number of for loops
	 * Number of classes
	 * Number of functions
	 * Number of single "{" on a line situation
	 * Number of all spaces
	 * Number of fields
	 */
    
        static ConstructParser c = new ConstructParser();
	
	static int numOfLines = 0;
	static int whileLoopCount = 0;
	static int forLoopCount = 0;
	static int comments = 0;
	static int ifCount = 0;
	static int classes = 0;
	static int bracketCount = 0;
	static int allSpaces = 0;
	static int codingStyle = 0;
	static int functions = 0;
	static int fields = 0;
        
	public static void main(String args[]) throws IOException, ClassNotFoundException
	{
		String singleComm = "//";
		String startBlockComm = "/*";
		String endBlockComm = "*/";

		String bracket = "{"; 
		/* 
		 * Used to check for situation where someone has the 
		 * following coding style:
		 * 	if(condition)	rather than if(condition){
		 * 	{
		 * 
		 * 	OR
		 * 
		 * 	while(condition)
		 * 	{
		 * 
		 * 	OR
		 * 
		 * 	public foo()
		 * 	{
		 */
		String header = "Class\tComments\tNumOfLines\tWhileCount\tForCount\tIfCondCount\tClassCount\tBracketCount\tAllSpaces\tCSS";
		writeHeader(header);
		String pseudonym = args[0];
		for(int i = 1; i<args.length; i++){
			System.out.println("Looking at file: " + i);
			/*numOfLines = 0;
			whileLoopCount = 0;
			forLoopCount = 0;
			comments = 0;
			ifCount = 0;
			classCount = 0;
			bracketCount = 0;
			allSpaces = 0;
			codingStyle = 0;*/
			
			FileInputStream fstream = new FileInputStream(args[i]);
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			while ((strLine = br.readLine()) != null) {
				
				//System.out.println("Line currently being looked at: " + strLine);
				
				numOfLines++;
				//allSpaces += countAllSpaces(strLine);
				
				/*
				 * Counts number of comments
				 * If it sees a block comment, it will skip lines until the
				 * end of the block comment is found
				 */
				
				if(strLine.contains(singleComm)) {
					//System.out.println(strLine);
					comments++;
					
					//line is a comment only
					if(strLine.trim().startsWith("//")){
						//System.out.println("Comment only line: " + strLine);
						continue;
					}
				} else if(strLine.contains(startBlockComm) && strLine.contains(endBlockComm)){
					comments++;
					//System.out.println(strLine);

					/*
					 * We know the line starts with /* but if it contains * / also
					 * then is must be a single line comment and we can skip it
					 */
					if(strLine.trim().startsWith("/*")){
						continue;
					}
				}
				
				/*
				 * Check for line that contains "{" as the only
				 * piece of code
				 */
				//if(singleOpenBracket(strLine, bracket)){
				//	bracketCount++;
				//	continue;
				//}
				
				
				
				

				/*
				 * Get the coding style spaces
				 * If needed, we can have individual features:
				 * one for the if condition
				 * one for the for loop
				 * one for the while loop
				 * As of now they are summed up together as a single sum
				 */
				codingStyle += test(strLine);
				
				/* 
				 * Put this after eveything else because checking the situation 
				 * where a block comment exists after some code is a little tricky
				 * and I did it after everything else
				*/
				if(strLine.contains(startBlockComm)  && !strLine.contains(endBlockComm)){
					//comments++;
					//System.out.println(strLine);
					/*
					 * Skip the lines in the block comment until we see a * / 
					 */
					for(;;){
						strLine = br.readLine();
						System.out.println(strLine);
						if(strLine.contains("*/")){
							break;
						}
					}
				}
				
			}
			in.close();
			checkFunction(args[0], args[i]);
			String s = "comments: " + comments + "\nnumOfLines: " + numOfLines + "\nwhileLoop: "
					+ whileLoopCount + "\nforLoop: " + forLoopCount + "\nifCount: " + ifCount + "\nclasses: "
					+ classes + "\nbracketCount:" + bracketCount + "\nall spaces: " + allSpaces + "\ncoding style spaces: " + codingStyle; 		
			System.out.println(s);		
			String fileStr = pseudonym + "\t" + comments + "\t\t" + numOfLines + "\t\t" + whileLoopCount + "\t\t" + forLoopCount + "\t\t" + ifCount + "\t\t" 
							+ classes + "\t\t" + bracketCount + "\t\t" + allSpaces + "\t\t" + codingStyle;
			writeData(fileStr);
		}
	}


	/*
	 * Counts all spaces, including those in comments
	 */
	public static int countAllSpaces(String s){
		int num = 0;
		for (int i = 0; i < s.length(); i++){
			if(s.charAt(i) == ' ')
				num++;
		}
		return num;
	}

	/*
	 * Checking coding style spaces
	 */ 
	public static int test(String s){
		//System.out.println("In Test");
		System.out.println("String: " + s);
		String temp = null;
		if(s.length() > 2 && s.contains("//")){
			//System.out.println("Comment after code, same line");
			int n = s.indexOf("//");
			//System.out.println("n: " + n);
			temp = s.substring(0, n-1);
			//System.out.println("after substring: " + temp); 
			
			/* 
			 * Clean up the string to remove unnecessary tabs that we dont care about 
			 */
			
			StringTokenizer st = new StringTokenizer(temp, "\t\n");
			temp = st.nextToken().trim();

			/* 
			 * Now that we have a clean string we need
			 * to check the different conditions
			 * mentioned above
			 */

			//System.out.println("after trim: " + temp); 
			//System.out.println("Coding style spaces: " + codingStyle(temp)); 
			return codingStyle(temp);
		}else if(s.length() > 2 && s.contains("/*")){ // same above but now with /* condition
			//System.out.println("Comment after code, same line");
			if(!s.startsWith("/*")){
				int n = s.indexOf("/*");
				//System.out.println("n: " + n);
				temp = s.substring(0, n-1);
			}
			//System.out.println("after substring: " + temp); 
			
			/* 
			 * Clean up the string to remove unnecessary tabs that we dont care about
			 */
			if(temp == null)
				return 0;
			
			StringTokenizer st = new StringTokenizer(temp, "\t\n");
			temp = st.nextToken().trim();
			
			/* 
			 * Now that we have a clean string we need
			 * to check the different conditions
			 * mentioned above
			 */

			//System.out.println("after trim: " + temp); 
			//System.out.println("Coding style spaces: " + codingStyle(temp)); 
			return codingStyle(temp);
		}

		/*
		 * If we are here that means line has no comments
		 */
		
		//System.out.println("No comments seen so far...");

		/* 
		 * Clean up the string to remove unnecessary tabs that we dont care about 
		 */
		
		//System.out.println("before trim: " + s);
		s = s.trim();
		//System.out.println("after trim: " + s); 
		
		/* 
		 * Now that we have a clean string we need
		 * to check the different conditions
		 * mentioned above
		 */
		
		//System.out.println("Coding style spaces: " + codingStyle(s)); 
		return codingStyle(s);
	}
        
	/*
	 * Check for situation where coding style is like the following:
	 * if(condition) 
	 * OR
	 * if(condition)
	 * OR
	 * if (condition)
	 * OR
	 * if ( condition )
	 * etc.
	 * Does the for while and for loops as well
	 */
	public static int codingStyle(String s){
		//System.out.println("check coding style");
		if(s.startsWith("if")){
			//System.out.println("IF: String: " + s);
			ifCount++;
			return c.check_if(s);
		}else if(s.startsWith("for")){
			System.out.println("FOR: String: " + s);
			forLoopCount++;
			return c.check_for(s);
		}else if(s.startsWith("while")){
			//System.out.println("WHILE: String: " + s);
			whileLoopCount++;
			return c.check_while(s);
		}

		return 0;
	}

	//to be implemented
	public static void checkFunction(String packName, String s) throws ClassNotFoundException {
		//pass in args[0] here too
		//String packName = "featureExtractor.";
		packName = packName.concat(".");
		//System.out.println("packName: " + packName);
		System.out.println("Before sub: " + s);
		int index = s.lastIndexOf("/");
		String className = s.substring(index+1, s.length());
		index = className.indexOf('.');
		className = className.substring(0, index);
		System.out.println("After sub: " + className);
		
		String fullPath = packName.concat(className);
		System.out.println("After concat: " + fullPath);

		
		Class<?> cls = Class.forName(fullPath); 
		functions += cls.getDeclaredMethods().length;
		classes += cls.getClasses().length;
		fields += cls.getDeclaredFields().length;
		//System.out.println("functions: " + functions + "\nclasses: " + classes + "\nfields: " + fields);
	}
	
	public static void writeHeader(String s) throws IOException{
		File file = new File("C:/Users/HOME/Desktop/features.txt");
		// if file doesnt exists, then create it
		if (!file.exists()) {
				file.createNewFile();
		}
		
		double bytes = file.length();
		if(bytes > 0){
			return;
		}

		FileWriter fw = new FileWriter("C:/Users/HOME/Desktop/features.txt", true);
		BufferedWriter bw = new BufferedWriter(fw);
		bw.write(s);
		bw.newLine();
		bw.close();
		
		System.out.println("\nDone writing header\n");
	}
	
	public static void writeData(String s) throws IOException{
		FileWriter fw = new FileWriter("C:/Users/HOME/Desktop/features.txt", true);
		BufferedWriter bw = new BufferedWriter(fw);
		bw.write(s);
		bw.newLine();
		bw.close();
		
		System.out.println("\nDone writing data\n");
	}
}
