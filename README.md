# impact-allowance
> 💷 Generate free school meal allowance usage statistics.

## Usage
1. Generate a detailed allowance report through Impact (Reports > Allowances > Detail List). 
1. Generate a list of all current FSM eligible students from SIMS (Reports > Student List > General Student List).
```
.\impact-allowance.ps1 -data impact.RTF -userfile users.txt



The following statistics are for 100 users.
They were allocated a total of 210.0 GBP.
They spent a total of 205.0 GBP.
They didn't spent a total of 2.9 GBP.
The FreeNoneSpent value was 2.1 GBP.
-
Averages per student:
2.1 GBP allocated.
2.05 GBP spent.
0.029 GBP unspent.
0.021 GBP FreeNoneSpent.
```

## License
[MIT](LICENSE)
