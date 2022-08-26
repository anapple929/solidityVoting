<template>
  <div id="app">
    <h2>投票DApp</h2>
    <div>
        <button v-if="!address" @click="connectWallet">连接小狐狸钱包</button>
    </div>
    <h2 v-if="address">
        当前登录的账户是：
        <strong>{{ address }}</strong>
    </h2>
<!-- 添加模块 -->
    <div v-if="address" style="float:left;width:45%;">
        <h3 style="color:blue">添加一个新的投票</h3>
        <input v-model="temp" placeholder="输入候选项"/>
        <!-- <input v-model="privateKey" placeholder="输入你的私钥"/> -->
        <button @click="addTemp">添加到候选区</button>
        <button @click="addVote">确认</button>
        <ul>
          <li v-for="tl in tempList" :key="tl">{{tl}}</li>
        </ul>
        <h2 v-show="newContractAddress">合约地址是：{{newContractAddress}}</h2>
        
    </div>
<!-- 投票模块 -->
    <div v-if="address" style="float:right;width:45%;">
      <h3 style="color:blue">投票模块</h3>
      <input v-model="contractAddress" placeholder="输入投票的合约地址"/>
      <button @click="showlist">查询</button>
      <button v-show="contractAddress" @click="showlist">刷新</button>
      <el-table :data="candidate" style="width: 100%">
        <el-table-column label="序号" width="70" align="center">
            <template slot-scope="scope">
                {{ scope.$index + 1 }}
            </template>
        </el-table-column>
        <el-table-column prop="nameN" label="候选人" style="width: 50%"></el-table-column>
        <el-table-column prop="total" label="票数" style="width: 15%"></el-table-column>
        
        <el-table-column label="pick" style="width: 25%">
          <template slot-scope="scope">
            <el-button type="primary" size="mini" icon="el-icon-edit" @click="addOne(scope.row.CanName)">选！</el-button>
          </template>
        </el-table-column>
        
      </el-table>
    </div>
  </div>
</template>

<script>
/* eslint-disable */
import { ethers } from 'ethers'
const provider = new ethers.providers.Web3Provider(
    ethereum,
);
const contractABI = [
	{
		"inputs": [
			{
				"internalType": "bytes32[]",
				"name": "candidateNames",
				"type": "bytes32[]"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "candidateList",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getCandidateLength",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "candidate",
				"type": "bytes32"
			}
		],
		"name": "totalVotesFor",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "candidate",
				"type": "bytes32"
			}
		],
		"name": "validCandidate",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "candidate",
				"type": "bytes32"
			}
		],
		"name": "voteForCandidate",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"name": "votesReceived",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
const bytecode = '0x60806040523480156200001157600080fd5b50604051620008403803806200084083398181016040528101906200003791906200018d565b80600190805190602001906200004f92919062000057565b5050620002e4565b82805482825590600052602060002090810192821562000096579160200282015b828111156200009557825182559160200191906001019062000078565b5b509050620000a59190620000a9565b5090565b5b80821115620000c4576000816000905550600101620000aa565b5090565b6000620000df620000d98462000207565b620001de565b90508083825260208201905082856020860282011115620001055762000104620002aa565b5b60005b858110156200013957816200011e888262000176565b84526020840193506020830192505060018101905062000108565b5050509392505050565b600082601f8301126200015b576200015a620002a5565b5b81516200016d848260208601620000c8565b91505092915050565b6000815190506200018781620002ca565b92915050565b600060208284031215620001a657620001a5620002b4565b5b600082015167ffffffffffffffff811115620001c757620001c6620002af565b5b620001d58482850162000143565b91505092915050565b6000620001ea620001fd565b9050620001f8828262000240565b919050565b6000604051905090565b600067ffffffffffffffff82111562000225576200022462000276565b5b602082029050602081019050919050565b6000819050919050565b6200024b82620002b9565b810181811067ffffffffffffffff821117156200026d576200026c62000276565b5b80604052505050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b600080fd5b600080fd5b600080fd5b600080fd5b6000601f19601f8301169050919050565b620002d58162000236565b8114620002e157600080fd5b50565b61054c80620002f46000396000f3fe608060405234801561001057600080fd5b50600436106100625760003560e01c80632f265cf714610067578063392e6678146100975780637021939f146100c7578063b13c744b146100f7578063cc9ab26714610127578063f7522a8314610143575b600080fd5b610081600480360381019061007c91906102d6565b610161565b60405161008e91906103bd565b60405180910390f35b6100b160048036038101906100ac91906102d6565b61019c565b6040516100be919061036c565b60405180910390f35b6100e160048036038101906100dc91906102d6565b6101ff565b6040516100ee91906103bd565b60405180910390f35b610111600480360381019061010c9190610303565b61021f565b60405161011e9190610387565b60405180910390f35b610141600480360381019061013c91906102d6565b610243565b005b61014b61029f565b60405161015891906103a2565b60405180910390f35b600061016c8261019c565b61017557600080fd5b60008083815260200190815260200160002060009054906101000a900460ff169050919050565b600080600090505b6001805490508110156101f45782600182815481106101c6576101c56104b4565b5b906000526020600020015414156101e15760019150506101fa565b80806101ec9061043c565b9150506101a4565b50600090505b919050565b60006020528060005260406000206000915054906101000a900460ff1681565b6001818154811061022f57600080fd5b906000526020600020016000915090505481565b61024c8161019c565b61025557600080fd5b600160008083815260200190815260200160002060008282829054906101000a900460ff1661028491906103d8565b92506101000a81548160ff021916908360ff16021790555050565b6000600180549050905090565b6000813590506102bb816104e8565b92915050565b6000813590506102d0816104ff565b92915050565b6000602082840312156102ec576102eb6104e3565b5b60006102fa848285016102ac565b91505092915050565b600060208284031215610319576103186104e3565b5b6000610327848285016102c1565b91505092915050565b6103398161040f565b82525050565b6103488161041b565b82525050565b61035781610425565b82525050565b6103668161042f565b82525050565b60006020820190506103816000830184610330565b92915050565b600060208201905061039c600083018461033f565b92915050565b60006020820190506103b7600083018461034e565b92915050565b60006020820190506103d2600083018461035d565b92915050565b60006103e38261042f565b91506103ee8361042f565b92508260ff0382111561040457610403610485565b5b828201905092915050565b60008115159050919050565b6000819050919050565b6000819050919050565b600060ff82169050919050565b600061044782610425565b91507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff82141561047a57610479610485565b5b600182019050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b600080fd5b6104f18161041b565b81146104fc57600080fd5b50565b61050881610425565b811461051357600080fd5b5056fea2646970667358221220d41c9ee33d408c0ea8a306a3d2ef73f69a2b216d9a88fb240824dc436d3da82e64736f6c63430008070033'

export default {
  name: 'App',
  data() {
      return {
          address: "", //登录账户的地址
          // count: 0
          contractAddress:'0x4a18fC2eaEA45EDFcAd005Be5E8FD4fc9231d389',//要查询的合约的地址
          candidate:[], //查出来的投票列表
          tempList:[], //临时列表
          temp:'',//临时项
          commitList:[], //把这个数组提交，创建一个新的合约
          // privateKey:'8b8652db900ff8a526bd2ddac53a70ff8256c6888ded69ad02303aa9a252993b', //私钥
          newContractAddress:'',
          signer:''
      }
  },
  created() {
      // this.getCount()
      this.tempList=[]
  },
  methods: {
      async connectWallet() {
          const { ethereum } = window
          if (ethereum === undefined){
            alert("请安装小狐狸钱包")
          } else{
            [this.address] = await provider.send("eth_requestAccounts", []);
            this.signer = provider.getSigner();
          }
      },
      async showlist(){
        this.candidate = []
        // console.log(this.contractAddress)
        const provider = new ethers.providers.Web3Provider(
            window.ethereum,
        );
        const signer = provider.getSigner()
        const ContractCounter = new ethers.Contract(this.contractAddress, contractABI, signer)
        
    
        var result =await ContractCounter.getCandidateLength()
        console.log(result);
        for(var i=0;i<result;i++){
            var CanName = await ContractCounter.candidateList(i)
            console.log(CanName)
            //this.candidate.name = CanName
            
            var total = await ContractCounter.totalVotesFor(CanName)
            // console.log(total)

            let output = Buffer.from(CanName.slice(2),'hex')
            console.log(output.toString('utf8'))
            var nameN=output.toString('utf8')

            this.candidate.push({CanName,total,nameN})
        }

        console.log(this.candidate)
      },
      addTemp(){
        this.tempList.push(this.temp);
        this.temp=''
        console.log(this.tempList)
      },
      async addVote(){
        for(let i = 0;i<this.tempList.length;i++){
          // this.tempList[i]
          let output = Buffer.from(this.tempList[i], 'utf8')
          // console.log(output.toString('hex'))
          let t = '0x'+output.toString('hex')
          this.commitList.push(t.padEnd(66,'0'))
        }
        console.log(this.commitList)
        console.log("私钥是+"+this.privateKey)
        /**************************************************** */
        //根据当前的用户，和commitList 创建一个新的合约
        // 常见合约工厂实例
        const provider = new ethers.providers.Web3Provider(
            window.ethereum,
        );
        

       // let wallet = new ethers.Wallet(this.privateKey, provider);
        let factory = new ethers.ContractFactory(contractABI,bytecode,this.signer)//this.commitList
        let contractObj = await factory.deploy(this.commitList)
        console.log('contractAddress=',contractObj.address)
        this.newContractAddress = contractObj.address
        //添加完，清空候选列表
        this.tempList=[]
      },
      async addOne(CanN){
        console.log(CanN)
        const provider = new ethers.providers.Web3Provider(
            window.ethereum,
        );
        const signer = provider.getSigner()
        const ContractCounter = new ethers.Contract(this.contractAddress, contractABI, signer)
        await ContractCounter.voteForCandidate(CanN)
        this.showlist()
      }
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
