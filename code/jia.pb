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

#JIA_EXTENSION_DIRECTORY = "extensions"

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	#JIA_PATH_SEPARATOR = "\"
CompilerElse
	#JIA_PATH_SEPARATOR = "/"
CompilerEndIf


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

Procedure.s GetArgumentAtIndex(List arguments.s(), index.i)
	
	SelectElement(arguments(), index)
	ProcedureReturn arguments()
EndProcedure

Procedure.s GetExtensionPath()
	
	ProcedureReturn GetPathPart(ProgramFilename()) + #JIA_EXTENSION_DIRECTORY + #JIA_PATH_SEPARATOR
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

Procedure.i CommandCmd(input.s, List arguments.s())
	Protected command.s
	
	command = GetArgumentAtIndex(arguments(), 0)
	input = Mid(Trim(input), Len(command) + 1)
	
	ProcedureReturn RunProgram(command, input, GetCurrentDirectory(), #PB_Program_Wait)
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

Procedure.i CommandGet(input.s, List arguments.s())
	
	If ListSize(arguments()) = 0
		ProcedureReturn #False
	EndIf
	
	FirstElement(arguments())
	PrintN(GetEnvironmentVariable(arguments()))
	ProcedureReturn #True
EndProcedure

Procedure.i CommandSet(input.s, List arguments.s())
	Protected name.s
	Protected value.s
	
	If ListSize(arguments()) <> 2
		ProcedureReturn #False
	EndIf
	
	name = GetArgumentAtIndex(arguments(), 0)
	value = GetArgumentAtIndex(arguments(), 1)
	
	SetEnvironmentVariable(name, value)
	
	ProcedureReturn #True
EndProcedure

Procedure.i CommandExtensions(input.s, List arguments.s())
	Protected directory.i
	Protected current.s
	Protected NewList extensionList.s()
	
	directory = ExamineDirectory(#PB_Any, GetExtensionPath(), "*.*")
	If Not directory
		ProcedureReturn #JIA_FAILURE
	EndIf
	
	While NextDirectoryEntry(directory)
		If DirectoryEntryType(directory) = #PB_DirectoryEntry_Directory
			Continue
		EndIf
		
		If DirectoryEntryAttributes(directory) & #PB_FileSystem_Hidden
			Continue
		EndIf
		
		current = LCase(GetFilePart(DirectoryEntryName(directory), #PB_FileSystem_NoExtension))
		If current = "." Or current = ".."
			Continue
		EndIf
		
		If Left(current, 1) = "."
			Continue
		EndIf
		
		ForEach extensionList()
			If extensionList() = current
				Continue
			EndIf
		Next
		
		AddElement(extensionList())
		extensionList() = current
	Wend
	FinishDirectory(directory)
	
	ForEach extensionList()
		PrintN(extensionList())
	Next
	
	ProcedureReturn #JIA_SUCCESS
EndProcedure

Procedure.i InitializeBuiltInCommands()
	
	SetBuiltInCommand("cmd", @CommandCmd())
	SetBuiltInCommand("cd", @CommandCurrentDirectory())
	SetBuiltInCommand("get", @CommandGet())
	SetBuiltInCommand("set", @CommandSet())
	SetBuiltInCommand("extensions", @CommandExtensions())
	
	ProcedureReturn #True
EndProcedure

Procedure.i ExecuteCommandExtension(command.s, input.s)
	Protected directory.i
	Protected currentExtension.s
	Protected exitCode.i
	
	directory = ExamineDirectory(#PB_Any, GetExtensionPath(), "*.*")
	If Not directory
		PrintN("Unknown Command; extension directory could not be examined.")
		ProcedureReturn #JIA_FAILURE
	EndIf
	
	exitCode = -1
	While NextDirectoryEntry(directory)
		If DirectoryEntryType(directory) = #PB_DirectoryEntry_Directory
			Continue
		EndIf
		
		If DirectoryEntryAttributes(directory) & #PB_FileSystem_Hidden
			Continue
		EndIf
		
		currentExtension = LCase(DirectoryEntryName(directory))
		If currentExtension = "." Or currentExtension = ".."
			Continue
		EndIf
		
		If GetFilePart(currentExtension, #PB_FileSystem_NoExtension) = command
			exitCode = RunProgram(GetExtensionPath() + currentExtension, input, GetCurrentDirectory(), #PB_Program_Wait)
			Break
		EndIf
	Wend
	FinishDirectory(directory)
	
	If exitCode < 0
		PrintN("Unknown Command.")
		ProcedureReturn #JIA_FAILURE
	EndIf
	
	ProcedureReturn exitCode
EndProcedure

Procedure.i ExecuteCommand(command.s, input.s, List arguments.s())
	Protected *delegate.BuiltInCommandPrototype
	
	*delegate = BuiltInCommandsMap(command)
	If *delegate
		ProcedureReturn *delegate(input, arguments())
	EndIf
	
	ProcedureReturn ExecuteCommandExtension(command, input)
EndProcedure

Procedure.i ExecuteCommandWithProgramArguments()
	Protected NewList arguments.s()
	Protected input.s
	Protected command.s
	Protected count.i
	Protected i.i
	
	count = CountProgramParameters() - 1
	command = ProgramParameter(0)
	For i = 1 To count
		AddElement(arguments())
		arguments() = ProgramParameter(i)
		input + ProgramParameter(i) + " "
	Next
	
	input = RTrim(input)
	ProcedureReturn ExecuteCommand(command, input, arguments())
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
	Protected exitCode.i
	
	If Not OpenConsole()
		ProcedureReturn #JIA_FAILURE
	EndIf
	
	InitializeBuiltInCommands()
	If CountProgramParameters() = 0
		ReadExecuteWriteLoop()
		exitCode = #JIA_SUCCESS
	Else
		exitCode = ExecuteCommandWithProgramArguments()
	EndIf
	
	CloseConsole()
	ProcedureReturn exitCode
EndProcedure : End EntryPoint()


; // end region





; IDE Options = PureBasic 5.20 beta 7 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 275
; FirstLine = 251
; Folding = -----
; EnableUnicode
; EnableXP
; CompileSourceDirectory