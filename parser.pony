type ParseResult is (USize, (ParseOK | ParseFail))

type ParseOK is
  ( AST
  | Token
  | NotPresent
  | Skipped
  | Lex
  )

primitive NotPresent
  """
  Returned by Option when the parse isn't found
  """

primitive Skipped
  """
  Returned by Skip when the parse is found, and Not when the parse isn't found.
  """

primitive Lex
  """
  Returned when a parse tree isn't neeeded
  """

primitive ParseFail
  """
  Returned when the parse isn't found.
  """

trait box Parser
  fun parse(source: String, offset: USize, tree: Bool, hidden: Parser)
    : ParseResult

  fun skip_hidden(source: String, offset: USize, hidden: Parser): USize =>
    """
    Return a new start location, skipping over hidden tokens.
    """
    hidden.parse(source, offset, false, NoParser)._1

  fun result(source: String, offset: USize, length: USize, tree: Bool)
    : ParseResult
  =>
    """
    Once a terminal parser has an offset and length, it should call `result` to
    return either a token (if a tree is requested) or a new lexical position.
    """
    if tree then
      (offset + length, Token(NoLabel, source, offset, length))
    else
      (offset + length, Lex)
    end

  // TODO: accept strings, turn them into literals
  fun mul(that: Parser): Sequence => Sequence(this, that)
  fun div(that: Parser): Choice => Choice(this, that)
  fun skip(): Skip => Skip(this)
  fun opt(): Option => Option(this)
  fun many(): Many => Many(this, false)
  fun many1(): Many => Many(this, true)
  fun op_not(): Not => Not(this)
  fun hide(that: Parser): Hidden => Hidden(this, that)
  fun term(): Terminal => Terminal(this)
  // fun label(): Parser => this // TODO: label the resulting token/AST

primitive NoParser is Parser
  fun parse(source: String, offset: USize, tree: Bool, hidden: Parser)
    : ParseResult
  =>
    (0, Lex)

trait val Label
  new val create()

primitive NoLabel is Label