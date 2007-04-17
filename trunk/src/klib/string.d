/+	klib.string
 +	(c) 2007 Alexander Panek
 +	Licensed under the ZLIB license
 +	Part of Project XANA
 +/
module klib.string;

char[] digits="0123456789";

int compare ( char [] s1, char [] s2 ) {
	if ( s1.length > s2.length ) return s1.length - s2.length;
	if ( s2.length > s2.length ) return s2.length - s1.length;

	uint i = 0;

	foreach ( char c; s1 ) {
		if ( c != s2[i] )
			break;

		i++;
	}

	return s1.length - i - 1;
}


char[] toString ( uint u ) {
 	char [uint.sizeof * 3] buffer = void;
    int ndigits;
    char c;
    char [] result;

    ndigits = 0;
    
	if (u < 10)	result = digits[u .. u + 1];		
    else {
		while (u)
		{
			c = (u % 10) + '0';
			u /= 10;
			ndigits++;
			buffer[buffer.length - ndigits] = c;
		}
		
		result = new char[ndigits];
		result[] = buffer[buffer.length - ndigits .. buffer.length];
    }

    return result;
}

