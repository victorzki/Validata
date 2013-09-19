/*
 * 12/06/2004
 *
 * AssemblerX86TokenMaker.java - An object that can take a chunk of text and
 * return a linked list of tokens representing X86 assembler.
 * 
 * This library is distributed under a modified BSD license.  See the included
 * RSyntaxTextArea.License.txt file for details.
 */
package org.fife.ui.rsyntaxtextarea.modes;

import java.io.*;
import javax.swing.text.Segment;

import org.fife.ui.rsyntaxtextarea.*;


/**
 * This class takes plain text and returns tokens representing x86
 * assembler.<p>
 *
 * This implementation was created using
 * <a href="http://www.jflex.de/">JFlex</a> 1.4.1; however, the generated file
 * was modified for performance.  Memory allocation needs to be almost
 * completely removed to be competitive with the handwritten lexers (subclasses
 * of <code>AbstractTokenMaker</code>, so this class has been modified so that
 * Strings are never allocated (via yytext()), and the scanner never has to
 * worry about refilling its buffer (needlessly copying chars around).
 * We can achieve this because RText always scans exactly 1 line of tokens at a
 * time, and hands the scanner this line as an array of characters (a Segment
 * really).  Since tokens contain pointers to char arrays instead of Strings
 * holding their contents, there is no need for allocating new memory for
 * Strings.<p>
 *
 * The actual algorithm generated for scanning has, of course, not been
 * modified.<p>
 *
 * If you wish to regenerate this file yourself, keep in mind the following:
 * <ul>
 *   <li>The generated AssemblerX86TokenMaker.java</code> file will contain two
 *       definitions of both <code>zzRefill</code> and <code>yyreset</code>.
 *       You should hand-delete the second of each definition (the ones
 *       generated by the lexer), as these generated methods modify the input
 *       buffer, which we'll never have to do.</li>
 *   <li>You should also change the declaration/definition of zzBuffer to NOT
 *       be initialized.  This is a needless memory allocation for us since we
 *       will be pointing the array somewhere else anyway.</li>
 *   <li>You should NOT call <code>yylex()</code> on the generated scanner
 *       directly; rather, you should use <code>getTokenList</code> as you would
 *       with any other <code>TokenMaker</code> instance.</li>
 * </ul>
 *
 * @author Robert Futrell
 * @version 0.2
 *
 */
%%

%public
%class AssemblerX86TokenMaker
%extends AbstractJFlexTokenMaker
%unicode
%ignorecase
%type org.fife.ui.rsyntaxtextarea.Token


%{


	/**
	 * Constructor.  We must have this here as JFLex does not generate a
	 * no parameter constructor.
	 */
	public AssemblerX86TokenMaker() {
		super();
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 */
	private void addToken(int tokenType) {
		addToken(zzStartRead, zzMarkedPos-1, tokenType);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 */
	private void addToken(int start, int end, int tokenType) {
		int so = start + offsetShift;
		addToken(zzBuffer, start,end, tokenType, so);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param array The character array.
	 * @param start The starting offset in the array.
	 * @param end The ending offset in the array.
	 * @param tokenType The token's type.
	 * @param startOffset The offset in the document at which this token
	 *                    occurs.
	 */
	@Override
	public void addToken(char[] array, int start, int end, int tokenType, int startOffset) {
		super.addToken(array, start,end, tokenType, startOffset);
		zzStartRead = zzMarkedPos;
	}


	/**
	 * Returns the text to place at the beginning and end of a
	 * line to "comment" it in a this programming language.
	 *
	 * @return The start and end strings to add to a line to "comment"
	 *         it out.
	 */
	@Override
	public String[] getLineCommentStartAndEnd() {
		return new String[] { ";", null };
	}


	/**
	 * Returns the first token in the linked list of tokens generated
	 * from <code>text</code>.  This method must be implemented by
	 * subclasses so they can correctly implement syntax highlighting.
	 *
	 * @param text The text from which to get tokens.
	 * @param initialTokenType The token type we should start with.
	 * @param startOffset The offset into the document at which
	 *                    <code>text</code> starts.
	 * @return The first <code>Token</code> in a linked list representing
	 *         the syntax highlighted text.
	 */
	public Token getTokenList(Segment text, int initialTokenType, int startOffset) {

		resetTokenList();
		this.offsetShift = -text.offset + startOffset;

		// Start off in the proper state.
		int state = Token.NULL;
		switch (initialTokenType) {
			default:
				state = Token.NULL;
		}

		s = text;
		try {
			yyreset(zzReader);
			yybegin(state);
			return yylex();
		} catch (IOException ioe) {
			ioe.printStackTrace();
			return new TokenImpl();
		}

	}


	/**
	 * Refills the input buffer.
	 *
	 * @return      <code>true</code> if EOF was reached, otherwise
	 *              <code>false</code>.
	 * @exception   IOException  if any I/O-Error occurs.
	 */
	private boolean zzRefill() throws java.io.IOException {
		return zzCurrentPos>=s.offset+s.count;
	}


	/**
	 * Resets the scanner to read from a new input stream.
	 * Does not close the old reader.
	 *
	 * All internal variables are reset, the old input stream 
	 * <b>cannot</b> be reused (internal buffer is discarded and lost).
	 * Lexical state is set to <tt>YY_INITIAL</tt>.
	 *
	 * @param reader   the new input stream 
	 */
	public final void yyreset(java.io.Reader reader) throws java.io.IOException {
		// 's' has been updated.
		zzBuffer = s.array;
		/*
		 * We replaced the line below with the two below it because zzRefill
		 * no longer "refills" the buffer (since the way we do it, it's always
		 * "full" the first time through, since it points to the segment's
		 * array).  So, we assign zzEndRead here.
		 */
		//zzStartRead = zzEndRead = s.offset;
		zzStartRead = s.offset;
		zzEndRead = zzStartRead + s.count - 1;
		zzCurrentPos = zzMarkedPos = zzPushbackPos = s.offset;
		zzLexicalState = YYINITIAL;
		zzReader = reader;
		zzAtBOL  = true;
		zzAtEOF  = false;
	}


%}

Letter				= ([A-Za-z_])
Digit				= ([0-9])
Number				= ({Digit}+)

Identifier			= (({Letter}|{Digit})[^ \t\f\n\,\.\+\-\*\/\%\[\]]+)

UnclosedStringLiteral	= ([\"][^\"]*)
StringLiteral			= ({UnclosedStringLiteral}[\"])
UnclosedCharLiteral		= ([\'][^\']*)
CharLiteral			= ({UnclosedCharLiteral}[\'])

CommentBegin			= ([;])

LineTerminator			= (\n)
WhiteSpace			= ([ \t\f])

Label				= (({Letter}|{Digit})+[\:])

Operator				= ("+"|"-"|"*"|"/"|"%"|"^"|"|"|"&"|"~"|"!"|"="|"<"|">")

%%

<YYINITIAL> {

	/* Keywords */
	".186" |
	".286" |
	".286P" |
	".287" |
	".386" |
	".386P" |
	".387" |
	".486" |
	".486P" |
	".586" |
	".586P" |
	".686" |
	".686P" |
	".8086" |
	".8087" |
	".ALPHA" |
	".BREAK" |
	".BSS" |
	".CODE" |
	".CONST" |
	".CONTINUE" |
	".CREF" |
	".DATA" |
	".DATA?" |
	".DOSSEG" |
	".ELSE" |
	".ELSEIF" |
	".ENDIF" |
	".ENDW" |
	".ERR" |
	".ERR1" |
	".ERR2" |
	".ERRB" |
	".ERRDEF" |
	".ERRDIF" |
	".ERRDIFI" |
	".ERRE" |
	".ERRIDN" |
	".ERRIDNI" |
	".ERRNB" |
	".ERRNDEF" |
	".ERRNZ" |
	".EXIT" |
	".FARDATA" |
	".FARDATA?" |
	".IF" |
	".K3D" |
	".LALL" |
	".LFCOND" |
	".LIST" |
	".LISTALL" |
	".LISTIF" |
	".LISTMACRO" |
	".LISTMACROALL" |
	".MMX" |
	".MODEL" |
	".MSFLOAT" |
	".NO87" |
	".NOCREF" |
	".NOLIST" |
	".NOLISTIF" |
	".NOLISTMACRO" |
	".RADIX" |
	".REPEAT" |
	".SALL" |
	".SEQ" |
	".SFCOND" |
	".STACK" |
	".STARTUP" |
	".TEXT" |
	".TFCOND" |
	".UNTIL" |
	".UNTILCXZ" |
	".WHILE" |
	".XALL" |
	".XCREF" |
	".XLIST" |
	".XMM" |
	"__FILE__" |
	"__LINE__" |
	"A16" |
	"A32" |
	"ADDR" |
	"ALIGN" |
	"ALIGNB" |
	"ASSUME" |
	"BITS" |
	"CARRY?" |
	"CATSTR" |
	"CODESEG" |
	"COMM" |
	"COMMENT" |
	"COMMON" |
	"DATASEG" |
	"DOSSEG" |
	"ECHO" |
	"ELSE" |
	"ELSEIF" |
	"ELSEIF1" |
	"ELSEIF2" |
	"ELSEIFB" |
	"ELSEIFDEF" |
	"ELSEIFE" |
	"ELSEIFIDN" |
	"ELSEIFNB" |
	"ELSEIFNDEF" |
	"END" |
	"ENDIF" |
	"ENDM" |
	"ENDP" |
	"ENDS" |
	"ENDSTRUC" |
	"EVEN" |
	"EXITM" |
	"EXPORT" |
	"EXTERN" |
	"EXTERNDEF" |
	"EXTRN" |
	"FAR" |
	"FOR" |
	"FORC" |
	"GLOBAL" |
	"GOTO" |
	"GROUP" |
	"HIGH" |
	"HIGHWORD" |
	"IEND" |
	"IF" |
	"IF1" |
	"IF2" |
	"IFB" |
	"IFDEF" |
	"IFDIF" |
	"IFDIFI" |
	"IFE" |
	"IFIDN" |
	"IFIDNI" |
	"IFNB" |
	"IFNDEF" |
	"IMPORT" |
	"INCBIN" |
	"INCLUDE" |
	"INCLUDELIB" |
	"INSTR" |
	"INVOKE" |
	"IRP" |
	"IRPC" |
	"ISTRUC" |
	"LABEL" |
	"LENGTH" |
	"LENGTHOF" |
	"LOCAL" |
	"LOW" |
	"LOWWORD" |
	"LROFFSET" |
	"MACRO" |
	"NAME" |
	"NEAR" |
	"NOSPLIT" |
	"O16" |
	"O32" |
	"OFFSET" |
	"OPATTR" |
	"OPTION" |
	"ORG" |
	"OVERFLOW?" |
	"PAGE" |
	"PARITY?" |
	"POPCONTEXT" |
	"PRIVATE" |
	"PROC" |
	"PROTO" |
	"PTR" |
	"PUBLIC" |
	"PURGE" |
	"PUSHCONTEXT" |
	"RECORD" |
	"REPEAT" |
	"REPT" |
	"SECTION" |
	"SEG" |
	"SEGMENT" |
	"SHORT" |
	"SIGN?" |
	"SIZE" |
	"SIZEOF" |
	"SIZESTR" |
	"STACK" |
	"STRUC" |
	"STRUCT" |
	"SUBSTR" |
	"SUBTITLE" |
	"SUBTTL" |
	"THIS" |
	"TITLE" |
	"TYPE" |
	"TYPEDEF" |
	"UNION" |
	"USE16" |
	"USE32" |
	"USES" |
	"WHILE" |
	"WRT" |
	"ZERO?"		{ addToken(Token.PREPROCESSOR); }

	"DB" |
	"DW" |
	"DD" |
	"DF" |
	"DQ" |
	"DT" |
	"RESB" |
	"RESW" |
	"RESD" |
	"RESQ" |
	"REST" |
	"EQU" |
	"TEXTEQU" |
	"TIMES" |
	"DUP"		{ addToken(Token.FUNCTION); }

	"BYTE" |
	"WORD" |
	"DWORD" |
	"FWORD" |
	"QWORD" |
	"TBYTE" |
	"SBYTE" |
	"TWORD" |
	"SWORD" |
	"SDWORD" |
	"REAL4" |
	"REAL8" |
	"REAL10"		{ addToken(Token.DATA_TYPE); }

	/* Registers */
	"AL" |
	"BL" |
	"CL" |
	"DL" |
	"AH" |
	"BH" |
	"CH" |
	"DH" |
	"AX" |
	"BX" |
	"CX" |
	"DX" |
	"SI" |
	"DI" |
	"SP" |
	"BP" |
	"EAX" |
	"EBX" |
	"ECX" |
	"EDX" |
	"ESI" |
	"EDI" |
	"ESP" |
	"EBP" |
	"CS" |
	"DS" |
	"SS" |
	"ES" |
	"FS" |
	"GS" |
	"ST" |
	"ST0" |
	"ST1" |
	"ST2" |
	"ST3" |
	"ST4" |
	"ST5" |
	"ST6" |
	"ST7" |
	"MM0" |
	"MM1" |
	"MM2" |
	"MM3" |
	"MM4" |
	"MM5" |
	"MM6" |
	"MM7" |
	"XMM0" |
	"XMM1" |
	"XMM2" |
	"XMM3" |
	"XMM4" |
	"XMM5" |
	"XMM6" |
	"XMM7" |
	"CR0" |
	"CR2" |
	"CR3" |
	"CR4" |
	"DR0" |
	"DR1" |
	"DR2" |
	"DR3" |
	"DR4" |
	"DR5" |
	"DR6" |
	"DR7" |
	"TR3" |
	"TR4" |
	"TR5" |
	"TR6" |
	"TR7"		{ addToken(Token.VARIABLE); }

	/* Pentium III Instructions. */
	"AAA" |
	"AAD" |
	"AAM" |
	"AAS" |
	"ADC" |
	"ADD" |
	"ADDPS" |
	"ADDSS" |
	"AND" |
	"ANDNPS" |
	"ANDPS" |
	"ARPL" |
	"BOUND" |
	"BSF" |
	"BSR" |
	"BSWAP" |
	"BT" |
	"BTC" |
	"BTR" |
	"BTS" |
	"CALL" |
	"CBW" |
	"CDQ" |
	"CLC" |
	"CLD" |
	"CLI" |
	"CLTS" |
	"CMC" |
	"CMOVA" |
	"CMOVAE" |
	"CMOVB" |
	"CMOVBE" |
	"CMOVC" |
	"CMOVE" |
	"CMOVG" |
	"CMOVGE" |
	"CMOVL" |
	"CMOVLE" |
	"CMOVNA" |
	"CMOVNAE" |
	"CMOVNB" |
	"CMOVNBE" |
	"CMOVNC" |
	"CMOVNE" |
	"CMOVNG" |
	"CMOVNGE" |
	"CMOVNL" |
	"CMOVNLE" |
	"CMOVNO" |
	"CMOVNP" |
	"CMOVNS" |
	"CMOVNZ" |
	"CMOVO" |
	"CMOVP" |
	"CMOVPE" |
	"CMOVPO" |
	"CMOVS" |
	"CMOVZ" |
	"CMP" |
	"CMPPS" |
	"CMPS" |
	"CMPSB" |
	"CMPSD" |
	"CMPSS" |
	"CMPSW" |
	"CMPXCHG" |
	"CMPXCHGB" |
	"COMISS" |
	"CPUID" |
	"CWD" |
	"CWDE" |
	"CVTPI2PS" |
	"CVTPS2PI" |
	"CVTSI2SS" |
	"CVTSS2SI" |
	"CVTTPS2PI" |
	"CVTTSS2SI" |
	"DAA" |
	"DAS" |
	"DEC" |
	"DIV" |
	"DIVPS" |
	"DIVSS" |
	"EMMS" |
	"ENTER" |
	"F2XM1" |
	"FABS" |
	"FADD" |
	"FADDP" |
	"FBLD" |
	"FBSTP" |
	"FCHS" |
	"FCLEX" |
	"FCMOVB" |
	"FCMOVBE" |
	"FCMOVE" |
	"FCMOVNB" |
	"FCMOVNBE" |
	"FCMOVNE" |
	"FCMOVNU" |
	"FCMOVU" |
	"FCOM" |
	"FCOMI" |
	"FCOMIP" |
	"FCOMP" |
	"FCOMPP" |
	"FCOS" |
	"FDECSTP" |
	"FDIV" |
	"FDIVP" |
	"FDIVR" |
	"FDIVRP" |
	"FFREE" |
	"FIADD" |
	"FICOM" |
	"FICOMP" |
	"FIDIV" |
	"FIDIVR" |
	"FILD" |
	"FIMUL" |
	"FINCSTP" |
	"FINIT" |
	"FIST" |
	"FISTP" |
	"FISUB" |
	"FISUBR" |
	"FLD1" |
	"FLDCW" |
	"FLDENV" |
	"FLDL2E" |
	"FLDL2T" |
	"FLDLG2" |
	"FLDLN2" |
	"FLDPI" |
	"FLDZ" |
	"FMUL" |
	"FMULP" |
	"FNCLEX" |
	"FNINIT" |
	"FNOP" |
	"FNSAVE" |
	"FNSTCW" |
	"FNSTENV" |
	"FNSTSW" |
	"FPATAN" |
	"FPREM" |
	"FPREMI" |
	"FPTAN" |
	"FRNDINT" |
	"FRSTOR" |
	"FSAVE" |
	"FSCALE" |
	"FSIN" |
	"FSINCOS" |
	"FSQRT" |
	"FST" |
	"FSTCW" |
	"FSTENV" |
	"FSTP" |
	"FSTSW" |
	"FSUB" |
	"FSUBP" |
	"FSUBR" |
	"FSUBRP" |
	"FTST" |
	"FUCOM" |
	"FUCOMI" |
	"FUCOMIP" |
	"FUCOMP" |
	"FUCOMPP" |
	"FWAIT" |
	"FXAM" |
	"FXCH" |
	"FXRSTOR" |
	"FXSAVE" |
	"FXTRACT" |
	"FYL2X" |
	"FYL2XP1" |
	"HLT" |
	"IDIV" |
	"IMUL" |
	"IN" |
	"INC" |
	"INS" |
	"INSB" |
	"INSD" |
	"INSW" |
	"INT" |
	"INTO" |
	"INVD" |
	"INVLPG" |
	"IRET" |
	"JA" |
	"JAE" |
	"JB" |
	"JBE" |
	"JC" |
	"JCXZ" |
	"JE" |
	"JECXZ" |
	"JG" |
	"JGE" |
	"JL" |
	"JLE" |
	"JMP" |
	"JNA" |
	"JNAE" |
	"JNB" |
	"JNBE" |
	"JNC" |
	"JNE" |
	"JNG" |
	"JNGE" |
	"JNL" |
	"JNLE" |
	"JNO" |
	"JNP" |
	"JNS" |
	"JNZ" |
	"JO" |
	"JP" |
	"JPE" |
	"JPO" |
	"JS" |
	"JZ" |
	"LAHF" |
	"LAR" |
	"LDMXCSR" |
	"LDS" |
	"LEA" |
	"LEAVE" |
	"LES" |
	"LFS" |
	"LGDT" |
	"LGS" |
	"LIDT" |
	"LLDT" |
	"LMSW" |
	"LOCK" |
	"LODS" |
	"LODSB" |
	"LODSD" |
	"LODSW" |
	"LOOP" |
	"LOOPE" |
	"LOOPNE" |
	"LOOPNZ" |
	"LOOPZ" |
	"LSL" |
	"LSS" |
	"LTR" |
	"MASKMOVQ" |
	"MAXPS" |
	"MAXSS" |
	"MINPS" |
	"MINSS" |
	"MOV" |
	"MOVAPS" |
	"MOVD" |
	"MOVHLPS" |
	"MOVHPS" |
	"MOVLHPS" |
	"MOVLPS" |
	"MOVMSKPS" |
	"MOVNTPS" |
	"MOVNTQ" |
	"MOVQ" |
	"MOVS" |
	"MOVSB" |
	"MOVSD" |
	"MOVSS" |
	"MOVSW" |
	"MOVSX" |
	"MOVUPS" |
	"MOVZX" |
	"MUL" |
	"MULPS" |
	"MULSS" |
	"NEG" |
	"NOP" |
	"NOT" |
	"OR" |
	"ORPS" |
	"OUT" |
	"OUTS" |
	"OUTSB" |
	"OUTSD" |
	"OUTSW" |
	"PACKSSDW" |
	"PACKSSWB" |
	"PACKUSWB" |
	"PADDB" |
	"PADDD" |
	"PADDSB" |
	"PADDSW" |
	"PADDUSB" |
	"PADDUSW" |
	"PADDW" |
	"PAND" |
	"PANDN" |
	"PAVGB" |
	"PAVGW" |
	"PCMPEQB" |
	"PCMPEQD" |
	"PCMPEQW" |
	"PCMPGTB" |
	"PCMPGTD" |
	"PCMPGTW" |
	"PEXTRW" |
	"PINSRW" |
	"PMADDWD" |
	"PMAXSW" |
	"PMAXUB" |
	"PMINSW" |
	"PMINUB" |
	"PMOVMSKB" |
	"PMULHUW" |
	"PMULHW" |
	"PMULLW" |
	"POP" |
	"POPA" |
	"POPAD" |
	"POPAW" |
	"POPF" |
	"POPFD" |
	"POPFW" |
	"POR" |
	"PREFETCH" |
	"PSADBW" |
	"PSHUFW" |
	"PSLLD" |
	"PSLLQ" |
	"PSLLW" |
	"PSRAD" |
	"PSRAW" |
	"PSRLD" |
	"PSRLQ" |
	"PSRLW" |
	"PSUBB" |
	"PSUBD" |
	"PSUBSB" |
	"PSUBSW" |
	"PSUBUSB" |
	"PSUBUSW" |
	"PSUBW" |
	"PUNPCKHBW" |
	"PUNPCKHDQ" |
	"PUNPCKHWD" |
	"PUNPCKLBW" |
	"PUNPCKLDQ" |
	"PUNPCKLWD" |
	"PUSH" |
	"PUSHA" |
	"PUSHAD" |
	"PUSHAW" |
	"PUSHF" |
	"PUSHFD" |
	"PUSHFW" |
	"PXOR" |
	"RCL" |
	"RCR" |
	"RDMSR" |
	"RDPMC" |
	"RDTSC" |
	"REP" |
	"REPE" |
	"REPNE" |
	"REPNZ" |
	"REPZ" |
	"RET" |
	"RETF" |
	"RETN" |
	"ROL" |
	"ROR" |
	"RSM" |
	"SAHF" |
	"SAL" |
	"SAR" |
	"SBB" |
	"SCAS" |
	"SCASB" |
	"SCASD" |
	"SCASW" |
	"SETA" |
	"SETAE" |
	"SETB" |
	"SETBE" |
	"SETC" |
	"SETE" |
	"SETG" |
	"SETGE" |
	"SETL" |
	"SETLE" |
	"SETNA" |
	"SETNAE" |
	"SETNB" |
	"SETNBE" |
	"SETNC" |
	"SETNE" |
	"SETNG" |
	"SETNGE" |
	"SETNL" |
	"SETNLE" |
	"SETNO" |
	"SETNP" |
	"SETNS" |
	"SETNZ" |
	"SETO" |
	"SETP" |
	"SETPE" |
	"SETPO" |
	"SETS" |
	"SETZ" |
	"SFENCE" |
	"SGDT" |
	"SHL" |
	"SHLD" |
	"SHR" |
	"SHRD" |
	"SHUFPS" |
	"SIDT" |
	"SLDT" |
	"SMSW" |
	"SQRTPS" |
	"SQRTSS" |
	"STC" |
	"STD" |
	"STI" |
	"STMXCSR" |
	"STOS" |
	"STOSB" |
	"STOSD" |
	"STOSW" |
	"STR" |
	"SUB" |
	"SUBPS" |
	"SUBSS" |
	"SYSENTER" |
	"SYSEXIT" |
	"TEST" |
	"UB2" |
	"UCOMISS" |
	"UNPCKHPS" |
	"UNPCKLPS" |
	"WAIT" |
	"WBINVD" |
	"VERR" |
	"VERW" |
	"WRMSR" |
	"XADD" |
	"XCHG" |
	"XLAT" |
	"XLATB" |
	"XOR" |
	"XORPS"		{ addToken(Token.RESERVED_WORD); }

}

<YYINITIAL> {

	{LineTerminator}				{ addNullToken(); return firstToken; }

	{WhiteSpace}+					{ addToken(Token.WHITESPACE); }

	/* String/Character Literals. */
	{CharLiteral}					{ addToken(Token.LITERAL_CHAR); }
	{UnclosedCharLiteral}			{ addToken(Token.ERROR_CHAR); /*addNullToken(); return firstToken;*/ }
	{StringLiteral}				{ addToken(Token.LITERAL_STRING_DOUBLE_QUOTE); }
	{UnclosedStringLiteral}			{ addToken(Token.ERROR_STRING_DOUBLE); addNullToken(); return firstToken; }

	/* Labels. */
	{Label}						{ addToken(Token.PREPROCESSOR); }

	^%({Letter}|{Digit})*			{ addToken(Token.FUNCTION); }

	/* Comment Literals. */
	{CommentBegin}.*				{ addToken(Token.COMMENT_EOL); addNullToken(); return firstToken; }

	/* Operators. */
	{Operator}					{ addToken(Token.OPERATOR); }

	/* Numbers */
	{Number}						{ addToken(Token.LITERAL_NUMBER_DECIMAL_INT); }

	/* Ended with a line not in a string or comment. */
	<<EOF>>						{ addNullToken(); return firstToken; }

	/* Catch any other (unhandled) characters. */
	{Identifier}					{ addToken(Token.IDENTIFIER); }
	.							{ addToken(Token.IDENTIFIER); }

}
