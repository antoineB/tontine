const Tontine = artifacts.require("Tontine");

contract('Tontine', (accounts) => {
  it('should start a tontine', async () => {
      const TontineInstance = await Tontine.deployed();
      const result = await TontineInstance.newTontine.call("test1", accounts);
      const info = await TontineInstance.info.call("test1");
      // TODO: doen't work
  });
});
