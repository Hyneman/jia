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
; // region ...Procedures....


Procedure.s ParseCommandFromInput(input.s)
	Protected command.s
	Protected *character.Character
	
	*character = @input
	While *character\c <> #Null
		
		If *character\c = ' '
			Break
		EndIf
		
		command + Chr(*character\c)
		*character + SizeOf(Character)
	Wend
	
	ProcedureReturn command
EndProcedure

Procedure.i ReadExecuteWriteLoop()
	Protected input.s
	Protected command.s
	
	Repeat
		ConsoleColor(#JIA_COLOR_PROMPT, #JIA_COLOR_BACKGROUND)
		Print(#JIA_PROMPT)
		ConsoleColor(#JIA_COLOR_TEXT, #JIA_COLOR_BACKGROUND)
		
		input = Input()
		command = LCase(ParseCommandFromInput(input))
		Select command
				
			Case "exit"
				Break
				
		EndSelect
	ForEver	
	
	ProcedureReturn #True
EndProcedure

Procedure.i EntryPoint()
	
	If Not OpenConsole()
		ProcedureReturn #JIA_FAILURE
	EndIf
	
	
	If CountProgramParameters() = 0
		ReadExecuteWriteLoop()
	EndIf
	
	CloseConsole()
	ProcedureReturn #JIA_SUCCESS
EndProcedure : End EntryPoint()


; // end region





; IDE Options = PureBasic 5.20 beta 7 (Windows - x86)
; CursorPosition = 44
; FirstLine = 31
; Folding = --
; EnableUnicode
; EnableXP