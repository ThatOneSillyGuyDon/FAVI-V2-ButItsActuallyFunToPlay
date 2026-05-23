package extensions.hscript;

import crowplexus.hscript.Parser;
import crowplexus.hscript.*;
import crowplexus.hscript.Expr;
import crowplexus.hscript.Tools;

using crowplexus.hscript.Tools;

using StringTools;

/**
 * Extended to read the `public` keyword.
 */
class ParserEx extends Parser
{
	override function parseStructure(id)
	{
		#if hscriptPos
		var p1 = tokenMin;
		#end
		
		return switch (id)
		{
			case "public":
				final e = parseExpr();
				
				switch (e.expr())
				{
					case EVar(name, _), EFunction(_, _, name) if (name != null):
						mk(EMeta(':sharable', [], e), tokenMin, tokenMax);
					default:
						unexpected(TId(id));
				}
				
			default:
				super.parseStructure(id);
		}
	}
	
	override function #if hscriptPos _token() #else token() #end { // oou gh.gh,gg,
		#if (!hscriptPos)
		if (!tokens.isEmpty())
			return tokens.pop();
		#end
		
		var char;
		if (this.char < 0)
			char = readChar();
		else {
			char = this.char;
			this.char = -1;
		}
		while (true) {
			if (StringTools.isEof(char)) {
				this.char = char;
				return TEof;
			}
			switch (char) {
				case 0: return TEof;
				case 32, 9, 13: #if hscriptPos tokenMin++; #end // space, tab, CR
				case 10:
					line++; // LF
					#if hscriptPos
					tokenMin++;
					#end
				case 48, 49, 50, 51, 52, 53, 54, 55, 56, 57: // 0...9
					var n = (char - 48) * 1.0;
					var exp = 0.;
					while (true) {
						char = readChar();
						exp *= 10;
						switch (char) {
							case 48, 49, 50, 51, 52, 53, 54, 55, 56, 57:
								n = n * 10 + (char - 48);
							case '_'.code:
							case "e".code, "E".code:
								var tk = token();
								var pow: Null<Int> = null;
								switch (tk) {
									case TConst(CInt(e)): pow = e;
									case TOp("-"):
										tk = token();
										switch (tk) {
											case TConst(CInt(e)): pow = -e;
											default: push(tk);
										}
									default:
										push(tk);
								}
								if (pow == null)
									invalidChar(char);
								return TConst(CFloat((Math.pow(10, pow) / exp) * n * 10));
							case ".".code:
								if (exp > 0) {
									// in case of '0...'
									if (exp == 10 && readChar() == ".".code) {
										push(TOp("..."));
										var i = Std.int(n);
										return TConst((i == n) ? CInt(i) : CFloat(n));
									}
									invalidChar(char);
								}
								exp = 1.;
							case "x".code:
								if (n > 0 || exp > 0)
									invalidChar(char);
								// read hexa
								#if haxe3
								var n = 0;
								while (true) {
									char = readChar();
									switch (char) {
										case 48, 49, 50, 51, 52, 53, 54, 55, 56, 57: // 0-9
											n = (n << 4) + char - 48;
										case 65, 66, 67, 68, 69, 70: // A-F
											n = (n << 4) + (char - 55);
										case 97, 98, 99, 100, 101, 102: // a-f
											n = (n << 4) + (char - 87);
										case '_'.code:
										default:
											this.char = char;
											return TConst(CInt(n));
									}
								}
								#else
								var n = haxe.Int32.ofInt(0);
								while (true) {
									char = readChar();
									switch (char) {
										case 48, 49, 50, 51, 52, 53, 54, 55, 56, 57: // 0-9
											n = haxe.Int32.add(haxe.Int32.shl(n, 4), cast(char - 48));
										case 65, 66, 67, 68, 69, 70: // A-F
											n = haxe.Int32.add(haxe.Int32.shl(n, 4), cast(char - 55));
										case 97, 98, 99, 100, 101, 102: // a-f
											n = haxe.Int32.add(haxe.Int32.shl(n, 4), cast(char - 87));
										case '_'.code:
										default:
											this.char = char;
											// we allow to parse hexadecimal Int32 in Neko, but when the value will be
											// evaluated by Interpreter, a failure will occur if no Int32 operation is
											// performed
											var v = try CInt(haxe.Int32.toInt(n)) catch (e:Dynamic) CInt32(n);
											return TConst(v);
									}
								}
								#end
							case "b".code: // Custom thing, not supported in haxe
								if (n > 0 || exp > 0)
									invalidChar(char);
								// read binary
								#if haxe3
								var n = 0;
								while (true) {
									char = readChar();
									switch (char) {
										case 48, 49: // 0-1
											n = (n << 1) + char - 48;
										case '_'.code:
										default:
											this.char = char;
											return TConst(CInt(n));
									}
								}
								#else
								var n = haxe.Int32.ofInt(0);
								while (true) {
									char = readChar();
									switch (char) {
										case 48, 49: // 0-1
											n = haxe.Int32.add(haxe.Int32.shl(n, 1), cast(char - 48));
										case '_'.code:
										default:
											this.char = char;
											// we allow to parse binary Int32 in Neko, but when the value will be
											// evaluated by Interpreter, a failure will occur if no Int32 operation is
											// performed
											var v = try CInt(haxe.Int32.toInt(n)) catch (e:Dynamic) CInt32(n);
											return TConst(v);
									}
								}
								#end
							default:
								this.char = char;
								var i = Std.int(n);
								return TConst((exp > 0) ? CFloat(n * 10 / exp) : ((i == n) ? CInt(i) : CFloat(n)));
						}
					}
				case ";".code:
					return TSemicolon;
				case "(".code:
					return TPOpen;
				case ")".code:
					return TPClose;
				case ",".code:
					return TComma;
				case ".".code:
					char = readChar();
					switch (char) {
						case 48, 49, 50, 51, 52, 53, 54, 55, 56, 57:
							var n = char - 48;
							var exp = 1;
							while (true)
							{
								char = readChar();
								exp *= 10;
								switch (char) {
									case 48, 49, 50, 51, 52, 53, 54, 55, 56, 57:
										n = n * 10 + (char - 48);
									default:
										this.char = char;
										return TConst(CFloat(n / exp));
								}
							}
						case ".".code:
							char = readChar();
							if (char != ".".code) invalidChar(char);
							return TOp("...");
						default:
							this.char = char;
							return TDot;
					}
				case "{".code:
					return TBrOpen;
				case "}".code:
					return TBrClose;
				case "[".code:
					return TBkOpen;
				case "]".code:
					return TBkClose;
				case "'".code:
					return readStringEx(char, true);
				case '"'.code:
					return readStringEx(char);
				case "?".code:
					char = readChar();
					if (char == ".".code)
						return TQuestionDot;
					else if (char == "?".code) {
						char = readChar();
						if (char == "=".code)
							return TOp("??" + "=");
						return TOp("??");
					}
					this.char = char;
					return TQuestion;
				case ":".code:
					return TDoubleDot;
				case '='.code:
					char = readChar();
					if (char == '='.code)
						return TOp("==");
					else if (char == '>'.code)
						return TOp("=>");
					this.char = char;
					return TOp("=");
				case '@'.code:
					char = readChar();
					if (idents[char] || char == ':'.code) {
						var id = String.fromCharCode(char);
						while (true) {
							char = readChar();
							if (!idents[char]) {
								this.char = char;
								return TMeta(id);
							}
							id += String.fromCharCode(char);
						}
					}
					invalidChar(char);
				case '#'.code:
					char = readChar();
					if (idents[char]) {
						var id = String.fromCharCode(char);
						while (true) {
							char = readChar();
							if (!idents[char]) {
								this.char = char;
								return preprocess(id);
							}
							id += String.fromCharCode(char);
						}
					}
					invalidChar(char);
				default:
					if (ops[char]) {
						var op = String.fromCharCode(char);
						while (true) {
							char = readChar();
							if (StringTools.isEof(char))
								char = 0;
							if (!ops[char]) {
								this.char = char;
								return TOp(op);
							}
							var pop = op;
							op += String.fromCharCode(char);
							if (!opPriority.exists(op) && opPriority.exists(pop)) {
								if (op == "//" || op == "/*")
									return tokenComment(op, char);
								this.char = char;
								return TOp(pop);
							}
						}
					}
					if (idents[char]) {
						var id = String.fromCharCode(char);
						while (true) {
							char = readChar();
							if (StringTools.isEof(char))
								char = 0;
							if (!idents[char]) {
								this.char = char;
								return TId(id);
							}
							id += String.fromCharCode(char);
						}
					}
					invalidChar(char);
			}
			char = readChar();
		}
		return null;
	}
	
	inline function parseEscape(c:Int, b:StringBuf, old:Int)
	{
		#if hscriptPos
		var p1 = (readPos - 1);
		#end
		
		switch (c)
		{
			case 'n'.code: b.addChar('\n'.code);
			case 'r'.code: b.addChar('\r'.code);
			case 't'.code: b.addChar('\t'.code);
			case "'".code, '"'.code, '\\'.code: b.addChar(c);
			case '/'.code: if( allowJSON ) b.addChar(c) else invalidChar(c);
			case "u".code:
				if( !allowJSON ) invalidChar(c);
				var k = 0;
				for( i in 0...4 )
				{
					k <<= 4;
					var char = readChar();
					switch( char ) {
					case 48,49,50,51,52,53,54,55,56,57: // 0-9
						k += char - 48;
					case 65,66,67,68,69,70: // A-F
						k += char - 55;
					case 97,98,99,100,101,102: // a-f
						k += char - 87;
					default:
						if( StringTools.isEof(char) )
						{
							line = old;
							error(EUnterminatedString, p1, p1);
						}
						invalidChar(char);
					}
				}
				b.addChar(k);
			default: invalidChar(c);
		}
	}
	
	function readStringEx(until:Int, interpolate:Bool = false)
	{
		var c = 0;
		var b = new StringBuf();
		var esc = false;
		var old = line;
		var s = input;
		#if hscriptPos
		var p1 = readPos - 1;
		#end
		
		while (true)
		{
			var c = readChar();
			if (StringTools.isEof(c))
			{
				line = old;
				error(EUnterminatedString, p1, p1);
				break;
			}
			if (esc)
			{
				esc = false;
				parseEscape(c, b, old);
			}
			else if (c == 92)
			{
				esc = true;
			}
			else if (c == until)
			{
				break;
			}
			else if (interpolate && c == '$'.code)
			{
				var next = readChar();
				if (idents[next] || next == '{'.code)
				{
					readPos --;
					return TConst( CString(b.toString(), true) );
				}
				else if (next == '$'.code)
				{
					b.addChar(c);
				}
				else
				{
					b.addChar(c);
					b.addChar(next);
				}
			}
			else
			{
				if (c == 10) line++;
				
				b.addChar(c);
			}
		}
		
		return TConst( CString(b.toString()) );
	}
	
	override function interpolateString(s:String)
	{
		var se = mk(EConst(CString(s)));
		
		while (true)
		{
			var e:Expr = null;
			
			var c = StringTools.fastCodeAt(input, readPos); // this is so Stupid
			if (idents[c])
			{
				var ident:String = '';
				while (true)
				{
					var c = readChar();
					if (!idents[c] || StringTools.isEof(c))
					{
						readPos --;
						break;
					}
					else
					{
						ident += String.fromCharCode(c);
					}
				}
				e = mk(EIdent(ident.toString()));
			}
			else
			{
				ensure(TBrOpen);
				e = parseExpr();
				ensure(TBrClose);
			}
			
			var r = readStringEx("'".code, true); // grab next bit of string
			
			switch (r)
			{
				case TConst(CString(s, i)):
					se = mk(EBinop('+', mk(EBinop('+', se, e)), mk(EConst(CString(s)))));
					
					if (i == null || !i) break;
					
				default:
			}
		}
		
		return mk(EParent(se));
	}
}
