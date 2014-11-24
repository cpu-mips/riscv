SECTIONS
{
    . = 0x00002000;
    .text : {
        * (.start);
        * (.text);
    }
}
