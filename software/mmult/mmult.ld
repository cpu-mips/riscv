SECTIONS
{
    . = 0x10010000;
    .text : {
        * (.start);
        * (.text);
    }
}
