A [tontine](https://en.wikipedia.org/wiki/Tontine) in solidity.

A tontine is created with `newTontine(uint amount, uint interval, string memory name, address payable[] memory contractors)`.
At every `interval` the `amount` should be payed (`pay(string memory name)`) by the participants in `contractors`.

If one contractor doesn't pay in time he is forbiden to continue.

When only one contractor remain it can `claim(string memory name)`.

