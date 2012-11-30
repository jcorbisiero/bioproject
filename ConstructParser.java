/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package featureExtractor;

/**
 *
 * @author Ilan
 */
public class ConstructParser {
    
        /*  
         *  Spaces within IF statement
         */
        static int for_forParen = 0;
        static int for_parenVariable = 0;
        static int for_variableSemi = 0;
        static int for_semiCondition = 0;
        static int for_conditionSemi = 0;
        static int for_semiIncrement = 0;
        static int for_incrementParen = 0;
        static int for_parenBracket = 0;
        static int for_bracketInline = 0;
        static int for_bracketNewline = 0;
        
        public ConstructParser(){
            
        }
        
        public static int check_if(String s){
		//System.out.println("check if");
		int count = 0;
		if(s == null)
			return count;

		for(int i = 2; i < s.length(); i++){
			//System.out.println("char: " + s.charAt(i));
			if(s.charAt(i) == ' '){
				count++;
			}
		}
		return count;
	}
        
        public static int check_while(String s){
		//System.out.println("check while");
		int count = 0;
		if(s == null)
			return count;

		for(int i = 5; i < s.length(); i++){
			//System.out.println("char: " + s.charAt(i));
			if(s.charAt(i) == ' '){
				count++;
			}
		}
		return count;
	}


	public int check_for(String s){
		//System.out.println("check for");
		
                int count = 0;
		int i = 0;
                
                if(s == null)
			return count;

                
                /* 
                 *  Get spacing between for and paren and between
                 *      parent and variable
                 */
                while( s.charAt(i) != '(' )
                    i++;
                assert(s.charAt(i) == '(');
                if( s.charAt( i - 1 ) == ' ')
                    for_forParen++;
                if( s.charAt( i + 1 ) == ' ')
                    for_parenVariable++;
                
                
                
                //Skip this next part if this is a foreach loop
                if( !isForEachLoop(s) )
                {
                
                    /*
                     * Get space between variable and comma and between
                     *      comma and condition
                     */
                    
                    //Skip variable declaration part
                    while( s.charAt(i) != ';')
                        i++;
                       
                    if( s.charAt(i-1) == ' ')
                        for_variableSemi++;
                    if( s.charAt(i+1) == ' ')
                        for_semiCondition++;
                    
                    
                    /*
                     * Get space between condition and comma and between
                     *  comma and increment
                     */
                    i++; //Advance past ';'
                    while( s.charAt(i) != ';')
                        i++;
                       
                    if( s.charAt(i-1) == ' ')
                        for_conditionSemi++;
                    if( s.charAt(i+1) == ' ')
                        for_semiIncrement++;
                    
                }
                
                /* 
                 *  Get spacing between condition and paren and between
                 *      parent and bracket
                 */             
                while(s.charAt(i) != ')')
                    i++;
                assert(s.charAt(i) == ')');
                if( s.charAt(i - 1) == ' ' )
                    for_incrementParen++;
                if( s.charAt(i + 1) == ' ')
                    for_parenBracket++;
                
                
                /*
                 *  Check if bracket is inline or on a new line
                 */
                if( s.substring(i).contains("{") )
                    for_bracketInline++;
                else
                    for_bracketNewline++;
		
                
                for(int j = 3; j < s.length(); j++){
			//System.out.println("char: " + s.charAt(i));
			if(s.charAt(j) == ' '){
				count++;
			}
                        
                        
		}
		return count;
	}
        
        
        
        /* Helper methods */
        
        public static boolean isForEachLoop(String s){
            return s.contains(":");
        }
        
    
}
