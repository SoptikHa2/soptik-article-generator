# Run as python3
# Make sure you have Pygments installed
# pip3 install --user pygments
#
# First argument: source code
# Second argument: language
import sys

def get_contents(filename):
    with open(filename, 'r') as myfile:
        return myfile.read()

# Check for correct import and arguments passed to script
try:
    from pygments import highlight
    from pygments.lexers import get_lexer_by_name
    from pygments.formatters import HtmlFormatter
except ImportError:
    print('Error: Python3 library "pygments" not found. Syntax highlighting won\'t be used.', file=sys.stderr)
    # Print whatever we received as source code
    if len(sys.argv) >= 2:
        print(get_contents(sys.argv[1]))
    sys.exit()
if len(sys.argv) < 3:
    print('Error: Expected source code and language name. Syntax highlighting won\'t be used.', file=sys.stderr)
    # Print whatever we received as source code
    if len(sys.argv) >= 2:
        print(get_contents(sys.argv[1]))
    sys.exit()

try:
    lexer = get_lexer_by_name(sys.argv[2])
    print(highlight(get_contents(sys.argv[1]), lexer, HtmlFormatter(lineseparator="<br/>")))
except:
    print("<pre>" + get_contents(sys.argv[1]) + "</pre>")

