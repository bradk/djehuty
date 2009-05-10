module core.regex;

import core.string;

import console.main;

import utils.stack;

class Regex
{
	// Description: This constructor will create an instance of a Regex that will efficiently compute the regular expression given.
	// regex: The regular expression to utilize.
	this(String regex)
	{
		regularExpression = new String(regex);

		buildDFA();
	}

	this(StringLiteral regex)
	{
		regularExpression = new String(regex);
		
		buildDFA();
	}
	
	// Description: This function will return a matched regular expression on the given String. Instances of a Regex will use a DFA based approach.
	// str: The String to run the regular expression upon.
	// Returns: The matched substring or null when no match could be found.
	String work(String str)
	{
		return null;
	}

	String work(StringLiteral str)
	{
		return work(new String(str));
	}

	// Description: This function will return a matched regular expression on the given String. Single use regular expression functions, such as this one, use a backtracking algorithm.
	// str: The String to run the regular expression upon.
	// regex: The regular expression to use.
	// Returns: The matched substring or null when no match could be found.
	static String work(String str, String regex)
	{
		int strPos;
		int regexPos;

		int currentGroupIdx = -1;
		int strPosStart;
		int regexPosStart;
		int regexFlagPotential;

		int flags;

		const int PLUS_OK = 1;
		const int LAZY_KLEENE = 2;
		const int KLEENE_MATCHED = 4;
		
		struct GroupInfo
		{
			int startPos;
			int endPos;
			int strStartPos;
			int strPos;
			int parent;
			int[int] failTable;
		}

		GroupInfo[int] groupInfo;
		int[int] operatorFlag;

		Stack!(int) groupStart = new Stack!(int)();
		Stack!(int) stack = new Stack!(int)();

		bool running = true;
		bool matchMade = true;
		bool backtrack = false;
		bool noMatch = false;
		int noMatchUntilClosedAtPos = 0;

		void setBacktrack(int newRegexPos, int newStrPos)
		{
			stack.push(newRegexPos);
			stack.push(newStrPos);
			stack.push(regexFlagPotential);
		}
		
		int findBackupRegexPosition()
		{
			int ret = regexPos - 1;
			if (ret in groupInfo)
			{
				ret = groupInfo[ret].startPos;
			}
			else
			{
				if (ret > 0 && regex[ret-1] == '\\')
				{
					ret--;
				}
			}
			return ret;
		}

		int findBackupPosition()
		{
			if (regexPos-1 in groupInfo)
			{
				return groupInfo[groupInfo[regexPos-1].startPos].strStartPos;
			}
			else
			{
				return strPos-1;
			}
		}

		setBacktrack(0,0);
		
		int[][] memoizer = new int[][](str.length, regex.length);

		// a+b in "bbaaaaaaabb" matches "aaaaaaaab"
		//Console.putln("attempting s:", strPos, " r:", regexPos);

		while(running)
		{
			//Console.putln("attempting s:", strPos, " r:", regexPos);
			if (strPos < str.length && regexPos < regex.length && matchMade)
			{
				if (memoizer[strPos][regexPos] == 1)
				{
					// we have been here before
					backtrack = true;
				}
				else
				{
					memoizer[strPos][regexPos] = 1;
				}
			}

			if (backtrack)
			{
				// steps are saved after successful matches
				// therefore the matchMade flag is always set
				matchMade = true;
				
				if (regexPos in groupInfo)
				{
					//Console.putln("Setting group fail info! r:", regexPos, " s:", groupInfo[regexPos].strStartPos);
					groupInfo[regexPos].failTable[groupInfo[regexPos].strStartPos] = 1;
				}

				regexFlagPotential = stack.pop();
				strPos = stack.pop();
				regexPos = stack.pop();
				if (regexPos == 0)
				{
					strPosStart++;
					strPos = strPosStart;

					if (strPosStart >= str.length)
					{
						// bad
						matchMade = false;
						running = false;
					}
				}

				backtrack = false;
				//Console.putln("backtracking s:", strPos, " r:", regexPos);
			}
			if (regexPos >= regex.length)
			{
				if (matchMade)
				{
					//Console.putln("good end");
					// good
					running = false;
				}
				else
				{
					// backtrack
					//regexPos = findBackupRegexPosition();
					//strPos = findBackupPosition();
					backtrack = true;
				}
			}
			else if (regex[regexPos] == '$')
			{
				//Console.putln("$ found at s:", strPos);
				if (strPos == str.length || str[strPos] == '\n' || str[strPos] == '\r')
				{
					matchMade = true;
				}
				else
				{
					//regexPos = findBackupRegexPosition();
					//strPos = findBackupPosition();
					backtrack = true;
					continue;
				}
				regexPos++;
			}
			else if (regex[regexPos] == '^')
			{
				if (strPos == 0 || str[strPos-1] == '\n' || str[strPos-1] == '\r')
				{
					matchMade = true;
				}
				else
				{
					//regexPos = findBackupRegexPosition();
					//strPos = findBackupPosition();
					backtrack = true;
					continue;
				}
				regexPos++;
			}
			else if (regex[regexPos] == '(' && (matchMade || noMatch))
			{	// group start
				if (!(regexPos in groupInfo))
				{
					GroupInfo newGroup;
					newGroup.startPos = regexPos;
					newGroup.endPos = -1;
					newGroup.strPos = strPos;
					newGroup.strStartPos = strPos;
					newGroup.parent = currentGroupIdx;

					groupInfo[regexPos] = newGroup;
				}
				else
				{
					// Memoizer for group failures
					if (strPos in groupInfo[regexPos].failTable)
					{
						//Console.putln("This group will have much fail");
						// this group will also fail
						backtrack = true;
						continue;
					}
				}

				if (regexPos < regex.length - 2 && regex[regexPos+1] == '?')
				{
					switch(regex[regexPos+2])
					{
						case '#':
							// comments
							break;
							
						case '>':
							// atomic grouping
							break;

						case ':':
							// non-capturing
							break;

						case '=':
							// zero-width positive lookahead
							break;

						case '!':
							// zero-width negative lookahead
							break;
							
						case '<':
							// zero-width lookbehind
							if (regexPos < regex.length - 3)
							{
								if (regex[regexPos+3] == '=')
								{
									// positive
								}
								else if (regex[regexPos+3] == '!')
								{
									// negative
								}
							}
							break;

						default:
							break;
					}
				}
				
				///Console.putln("group r:" , regexPos, " entered at s:", strPos);
				
				groupInfo[regexPos].strPos = strPos;
				currentGroupIdx = regexPos;
				regexPos++;
			}
			else if (regex[regexPos] == ')')
			{	// group end
				if (!(regexPos in groupInfo))
				{
					groupInfo[currentGroupIdx].endPos = regexPos;
					groupInfo[regexPos] = groupInfo[currentGroupIdx];

					//Console.putln("group map: ", currentGroupIdx, " -> ", regexPos);

					if (currentGroupIdx == noMatchUntilClosedAtPos)
					{
						noMatch = false;
					}
				}

				if (noMatch && noMatchUntilClosedAtPos == groupInfo[regexPos].startPos)
				{
					noMatch = false;
				}

				if (matchMade)
				{
					//Console.putln("group r:", groupInfo[regexPos].startPos, " match s:", strPos, " r:", regexPos);
					groupInfo[groupInfo[regexPos].startPos].strPos = strPos;
				}
				else
				{
					//Console.putln("group r:", groupInfo[regexPos].startPos, " fail s:", strPos, " r:", regexPos);
					strPos = groupInfo[groupInfo[regexPos].startPos].strPos;
				}

				currentGroupIdx = groupInfo[regexPos].parent;
				if (currentGroupIdx == -1)
				{
					//Console.putln("currentGroupIdx: -1");
				}
				else
				{
					//Console.putln("currentGroupIdx: ", currentGroupIdx);
				}
				regexPos++;
				//Console.putln("attempting s:", strPos, " r:", regexPos);
			}
			else if (noMatch)
			{
				regexPos++;
			}
			else if (regex[regexPos] == '*')
			{
				// kleene star

				//Console.putln("kleene* s:", strPos, " r:", regexPos);

				if (regexPos < regex.length - 1 && regex[regexPos+1] == '?')
				{
					// this is a lazy kleene

					//Console.putln("kleene*? s:", strPos, " r:", regexPos);

					// it may have matched something, but it should ignore the work
					// for now that it had done and save it as part of the lazy operator

					if (matchMade)
					{
						// set backtrack to do another computation
						setBacktrack(findBackupRegexPosition(), strPos);
						
						if (!(regexPos in operatorFlag))
						{
							// we have made a match, but have not attempted
							// to try not matching anything first

							// set the flag so that this operator knows that it has
							// already found a match
							operatorFlag[regexPos] = strPos;
							regexFlagPotential = regexPos;

							// set backtrack to start where this one would have
							// continued to
							setBacktrack(regexPos+2, strPos);

							// and then start all over by assuming nothing is taken
							strPos = findBackupPosition();
							regexPos+=2;
						}
						else
						{
							// we have already found a match
							// just continue on our way
							regexPos+=2;
						}
					}
					else
					{
						// the group fails, it is ok
						matchMade = true;
						regexPos+=2;
					}
				}
				else if (matchMade)
				{
					// this is a greedy kleene
					
					// the backtrack will suggest to just go to the next regex
					// character at this same string. this computation path,
					// however, will be attempting to match the previous group
					// as much as possible
					
					// we need to set a backtrack for having not matched anything even though
					// something was just matched. It could be that what we matched belongs to
					// another section of the regex.
					if (!(regexPos in operatorFlag) || regexFlagPotential < regexPos)
					{
						// set a backtrack for having nothing found
						setBacktrack(regexPos+1,findBackupPosition());
					}

					operatorFlag[regexPos] = 1;

					setBacktrack(regexPos+1, strPos);
					regexPos--;
					if (regexPos in groupInfo)
					{
						regexPos = groupInfo[regexPos].startPos;
						currentGroupIdx = regexPos;
					}
					else
					{
						if (regexPos > 0 && regex[regexPos-1] == '\\')
						{
							regexPos--;
						}
					}
				}
				else
				{
					// it is ok
					matchMade = true;
					regexPos++;
				}
				//Console.putln("attempting s:", strPos, " r:", regexPos);
			}
			else if (regex[regexPos] == '+')
			{
				// kleene plus

				//Console.putln("kleene+ s:", strPos, " r:", regexPos);
				
				if (regexPos < regex.length - 1 && regex[regexPos+1] == '?')
				{
					// this is a lazy kleene

					//Console.putln("kleene+? s:", strPos, " r:", regexPos);

					if (matchMade)
					{
						// good, continue and set a backtrack to attempt another
						// match on this kleene

						// set the flag so that this operator knows that it has
						// already found a match
						operatorFlag[regexPos] = 1;
						regexFlagPotential = regexPos;

						// set the backtrace
						int newRegexPos = regexPos+2;

						regexPos--;
						if (regexPos in groupInfo)
						{
							regexPos = groupInfo[regexPos].startPos;
							currentGroupIdx = regexPos;
						}
						else
						{
							if (regexPos > 0 && regex[regexPos-1] == '\\')
							{
								regexPos--;
							}
						}

						setBacktrack(regexPos, strPos);

						regexPos = newRegexPos;
					}
					else
					{
						if (regexPos in operatorFlag && regexFlagPotential >= regexPos)
						{
							// we have not found any matches at all
							// fail the op
							//regexPos = findBackupRegexPosition();
							//strPos = findBackupPosition();
							backtrack = true;
							continue;
						}
						else
						{
							// it is ok, we found at least one
							matchMade = true;
							regexPos+=2;
						}
					}
				}
				else if (matchMade)
				{
					// this is a greedy kleene

					// the backtrack will suggest to just go to the next regex
					// character at this same string. this computation path,
					// however, will be attempting to match the previous group
					// as much as possible

					setBacktrack(regexPos+1, strPos);

					// set the flag so that this operator knows that it has
					// already found a match
					operatorFlag[regexPos] = 1;
					regexFlagPotential = regexPos;

					regexPos--;
					if (regexPos in groupInfo)
					{
						regexPos = groupInfo[regexPos].startPos;
						currentGroupIdx = regexPos;
					}
					else
					{
						if (regexPos > 0 && regex[regexPos-1] == '\\')
						{
							regexPos--;
						}
					}
				}
				else
				{
					// it is ok
					if (regexPos in operatorFlag && regexFlagPotential >= regexPos)
					{
						// good
						matchMade = true;
						regexPos++;
					}
					else
					{
						// fail the op
						//regexPos = findBackupRegexPosition();
						//strPos = findBackupPosition();
						backtrack = true;
						continue;
					}
				}
				//Console.putln("attempting s:", strPos, " r:", regexPos);
			}
			else if (regex[regexPos] == '?')
			{
				// option
				regexPos++;
				if (regexPos < regex.length && regex[regexPos] == '?')
				{
					// lazy option
					regexPos++;
					if (matchMade)
					{
						// unfortunately, this work that has been done
						// has been done in vain. We want to attempt to
						// not consume this option.

						// set the backtrack to backtrack to the current
						// situation (taking the option)
						setBacktrack(regexPos, strPos);
						
						// now, attempt to carry on to the next part of
						// the regex while undoing the last group
						strPos = findBackupPosition();
					}
					else
					{
						// very good, only one possible outcome: no match
						matchMade = true;
					}
				}
				else if (matchMade)
				{
					// greedy option

					// backtrack to not taking the option
					setBacktrack(regexPos, findBackupPosition());
				}
				else
				{
					// greedy option
					matchMade = true;
				}
			}
			else if (!matchMade)
			{
				// the group fails if a concatentation fails
				if (currentGroupIdx >= 0)
				{
					//Console.putln("failed within group group:", currentGroupIdx, " endPos:", groupInfo[currentGroupIdx].endPos);
					if (groupInfo[currentGroupIdx].endPos >= 0)
					{
						regexPos = groupInfo[currentGroupIdx].endPos;
					}
					else
					{
						noMatch = true;
						noMatchUntilClosedAtPos = currentGroupIdx;
					}
				}
				else
				{
					//Console.putln("failed outside group");
					//regexPos = findBackupRegexPosition();
					//strPos = findBackupPosition();
					backtrack = true;
					continue;
				}
			}
			else
			{
				// concatentation
				if (regex[regexPos] == '\\' && regexPos < regex.length-1)
				{
					regexPos++;
					if (strPos >= str.length)
					{
						matchMade = false;
					}
					else
					{
						switch(regex[regexPos])
						{
							case 'd':
								matchMade = (str[strPos] >= '0' && str[strPos] <= '9');
								break;
	
							case 'D':
								matchMade = !(str[strPos] >= '0' && str[strPos] <= '9');
								break;
	
							case 's':
								matchMade = (str[strPos] == ' '
											|| str[strPos] == '\t'
											|| str[strPos] == '\r'
											|| str[strPos] == '\n'
											|| str[strPos] == '\v'
											|| str[strPos] == '\f');
								break;
								
							case 'S':
								matchMade = (str[strPos] != ' '
											&& str[strPos] != '\t'
											&& str[strPos] != '\r'
											&& str[strPos] != '\n'
											&& str[strPos] != '\v'
											&& str[strPos] != '\f');
								break;
	
							case 'w':
								matchMade = (str[strPos] == '_'
											|| (str[strPos] >= 'a' && str[strPos] <= 'z')
											|| (str[strPos] >= 'A' && str[strPos] <= 'Z'));
								break;
								
							case 'W':
								matchMade = (str[strPos] != '_'
											&& (str[strPos] < 'a' || str[strPos] > 'z')
											&& (str[strPos] < 'A' || str[strPos] > 'Z'));
								break;
								
							case 'n':
								matchMade = str[strPos] == '\n';
								break;
	
							case 'e':
								matchMade = str[strPos] == '\x1b';
								break;
	
							case 'v':
								matchMade = str[strPos] == '\v';
								break;
	
							case 't':
								matchMade = str[strPos] == '\t';
								break;
	
							case 'r':
								matchMade = str[strPos] == '\r';
								break;
	
							case 'a':
								matchMade = str[strPos] == '\a';
								break;
	
							default:
								matchMade = str[strPos] == regex[regexPos];
								break;
						}
					}
				}
				else if (strPos < str.length && ((str[strPos] == regex[regexPos]) || (regex[regexPos] == '.')))
				{
					// match made
					matchMade = true;
				}
				else
				{
					// no match made
					matchMade = false;
				}

				if (matchMade)
				{
					//Console.putln("match s:", strPos, " r:", regexPos);

					// match made
					matchMade = true;

					// consume input string
					strPos++;
				}
				else
				{
					//Console.putln("fail s:", strPos, " r:", regexPos);
				}

				// consume
				regexPos++;
			}
		}

		// Return the result
		if (matchMade && strPosStart <= str.length)
		{
			if (strPos-strPosStart == 0)
			{
				return new String("");
			}
			return str.subString(strPosStart, strPos-strPosStart);
		}
		
		return null;
	}

	static String work(StringLiteral str, String regex)
	{
		return work(new String(str), regex);
	}

	static String work(String str, StringLiteral regex)
	{
		return work(str, new String(regex));
	}

	static String work(StringLiteral str, StringLiteral regex)
	{
		return work(new String(str), new String(regex));
	}
	
protected:

	// These instance variables contain the data structures
	// that will build and maintain the DFA for the regular expression
	
	// Holds the regular expression for the instance
	String regularExpression;

	void buildDFA()
	{
	}
}