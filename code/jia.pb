; ////
; //////
; //////       J I A   S H E L L   E N V I R O N M E N T
; ////// ==============================
; //////
; ////// SILENTBYTE LICENSE NOTICE
; //////
; ////// THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS' AND ANY EXPRESSED OR IMPLIED
; ////// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
; ////// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
; ////// EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
; ////// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
; ////// PROCUREMENT OF SUBSTITUTEGOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
; ////// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
; ////// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ////// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; ////// POSSIBILITY OF SUCH DAMAGE.
; ////// 
; ////// THE CODE OF JIA FOUND IN THIS SOURCE FILE IS USING THE GPLv3 LICENSE.
; ////// FURTHER INFORMATION CAN BE FOUND IN THE ACCORDING LICENSE FILE.
; ////



EnableExplicit


; // region ...Compiler Constraints...


CompilerIf Not #PB_Compiler_Unicode
	CompilerError "Unicode Support has to be enabled in order to compile this project."
CompilerEndIf


; // end region
; // region ...Constants...


#JIA_SUCCESS = 0
#JIA_FAILURE = 1

#JIA_PROMPT = "> jia "

#JIA_COLOR_PROMPT = 10
#JIA_COLOR_TEXT = 7
#JIA_COLOR_BACKGROUND = 0


; // end region
; // region ...Structures...


Structure CharArray
	c.c[0]
EndStructure


; // end region
; // region ...Prototypes...


Prototype.i BuiltInCommandPrototype(input.s, List arguments.s())


; // end region
; // region ...Globals...


; // Use integer type because PureBasic is still not able to support prototypes with maps (*sigh*).
Global NewMap BuiltInCommandsMap.i()


; // end region
; // region ...Procedures....


Procedure.i IsWhiteSpace(character.c)
	
	Select character
		Case $0020, $00A0, $1680, $180E, $2000,
		     $2001, $2002, $2003, $2004,
		     $2005, $2006, $2007, $2008,
		     $2009, $200A, $200B, $202F,
		     $205F, $3000, $FEFF
			ProcedureReturn #True
			
	EndSelect
	
	ProcedureReturn #False
EndProcedure

Procedure.s ParseCommandFromInput(input.s)
	Protected command.s
	Protected *character.Character
	
	*character = @input
	While *character\c <> #Null
		
		If IsWhiteSpace(*character\c)
			Break
		EndIf
		
		command + Chr(*character\c)
		*character + SizeOf(Character)
	Wend
	
	ProcedureReturn command
EndProcedure

Procedure.i ParseCommandArgumentsFromInput(input.s, List arguments.s())
	Protected *input.CharArray
	Protected counter.i
	Protected current.s
	Protected isQuoted.i
	
	*input = @input
	counter = 0
	isQuoted = #False
	
	ClearList(arguments())
	While *input\c[counter] <> #Null
		If isQuoted
			If *input\c[counter] = '"'
				If *input\c[counter + 1] = '"'
					current + #DQUOTE$
					counter + 2
				Else
					isQuoted = #False
					counter + 1
				EndIf
			Else
				current + Chr(*input\c[counter])
				counter + 1
			EndIf
		ElseIf *input\c[counter] = '"'
			isQuoted = #True
			counter + 1
		ElseIf IsWhiteSpace(*input\c[counter])
			AddElement(arguments())
			arguments() = current
			
			current = ""
			counter + 1
		Else
			current + Chr(*input\c[counter])
			counter + 1
		EndIf			
	Wend
	
	If current
		AddElement(arguments())
		arguments() = current
	EndIf

	ProcedureReturn #False
EndProcedure

Procedure.i WritePrompt()
	
	ConsoleColor(#JIA_COLOR_PROMPT, #JIA_COLOR_BACKGROUND)
	Print(#JIA_PROMPT)
	ConsoleColor(#JIA_COLOR_TEXT, #JIA_COLOR_BACKGROUND)
	
	ProcedureReturn #True
EndProcedure

Procedure.i SetBuiltInCommand(command.s, *callback.BuiltInCommandPrototype)
	
	If command = "" Or *callback = #Null
		ProcedureReturn #False
	EndIf
	
	BuiltInCommandsMap(command) = *callback
	ProcedureReturn #True
EndProcedure

Procedure.i CommandCurrentDirectory(input.s, List arguments.s())
	
	input = Trim(input)
	If input = ""
		PrintN(GetCurrentDirectory())
	Else
		SetCurrentDirectory(input)
	EndIf
	
	ProcedureReturn #True
EndProcedure

Procedure.i InitializeBuiltInCommands()
	
	BuiltInCommandsMap("cd") = @CommandCurrentDirectory()
	
	ProcedureReturn #True
EndProcedure

Procedure.i ExecuteCommand(command.s, input.s, List arguments.s())
	Protected *delegate.BuiltInCommandPrototype
	
	*delegate = BuiltInCommandsMap(command)
	If *delegate
		ProcedureReturn *delegate(input, arguments())
	EndIf
	
	ProcedureReturn #False
EndProcedure

Procedure.i ReadExecuteWriteLoop()
	Protected input.s
	Protected command.s
	Protected NewList arguments.s()
	
	Repeat
		WritePrompt()
		
		input = Trim(Input())
		If input = ""
			Continue
		EndIf
		
		ParseCommandArgumentsFromInput(input, arguments())
		
		FirstElement(arguments())
		command = LCase(arguments())
		DeleteElement(arguments(), 1)
		
		If command = "exit"
			Break
		EndIf
		
		ExecuteCommand(command, Mid(input, Len(command) + 1), arguments())
	ForEver	
	
	ProcedureReturn #True
EndProcedure

Procedure.i EntryPoint()
	
	If Not OpenConsole()
		ProcedureReturn #JIA_FAILURE
	EndIf
	
	InitializeBuiltInCommands()
	If CountProgramParameters() = 0
		ReadExecuteWriteLoop()
	EndIf
	
	CloseConsole()
	ProcedureReturn #JIA_SUCCESS
EndProcedure : End EntryPoint()


; // end region





; IDE Options = PureBasic 5.20 beta 7 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 175
; FirstLine = 123
; Folding = ---
; EnableUnicode
; EnableXP