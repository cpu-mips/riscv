SECTIONS
{
    . = 0x40002000;
    .text : {
        * (.start);
        * (.text);
    }
}
