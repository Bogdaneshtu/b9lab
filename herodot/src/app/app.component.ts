import { Component, HostListener, NgZone } from '@angular/core';
const Web3 = require('web3');
const contract = require('truffle-contract');
const metaincoinArtifacts = require('../../build/contracts/MetaCoin.json');
const herodotArtifacts = require('../../build/contracts/Herodot.json');

import { canBeNumber } from '../util/validation';
import {HistoryEvent} from "./app.component.model";
import {reject} from "q";

declare var window: any;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent {
  MetaCoin = contract(metaincoinArtifacts);
  Herodot = contract(herodotArtifacts);

  // TODO add proper types these variables
  account: any;
  accounts: any;
  web3: any;

  balance: number;

  status: string;

  events: any[];
  maxIndex: number;
  totalItems: number;
  media: string;
  title: string;
  description: string;

  constructor(private _ngZone: NgZone) {

  }

  @HostListener('window:load')
  windowLoaded() {
    this.maxIndex = -1;
    this.refreshTotalItems();
    this.checkAndInstantiateWeb3();
    this.onReady();
    this.refreshMaxIndex();
    setInterval(this.refreshMaxIndex, 1000);
  }

  refreshTotalItems = () => {
    this.totalItems = Number(1) + Number(this.maxIndex);
  };

  checkAndInstantiateWeb3 = () => {
    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof window.web3 !== 'undefined') {
      console.warn(
        'Using web3 detected from external source. If you find that your accounts don\'t appear or you have 0 MetaCoin, ensure you\'ve configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask'
      );
      // Use Mist/MetaMask's provider
      this.web3 = new Web3(window.web3.currentProvider);
    } else {
      console.warn(
        'No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it\'s inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask'
      );
      // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
      this.web3 = new Web3(
        new Web3.providers.HttpProvider(Web3.currentProvider)
      );
    }
  };

  refreshMaxIndex = () => {
    this.Herodot
      .deployed()
      .then(instance => {
        return instance.getMaximalIndex.call();
      })
      .then(newIndexValue => {
        if(this.maxIndex.toString() !== newIndexValue.toString()) {
          this.maxIndex = newIndexValue;
          this.refreshTotalItems();
          this.loadAllHistoryEvents();
        }
      })
      .catch(e => {
        console.log(e);
        this.setStatus('Error getting max index; see log.');
      });
  };

  loadAllHistoryEvents = (currentIndex, moreTimes) => {
    this.events = [];
    for (let i = 0; i <= this.maxIndex; i++) {
      this.events.push(event);
    }
  };

  getEvent = (index) => {
    return new Promise((resolve, reject) => {
      this.Herodot
        .deployed()
        .then(instance => {
          return instance.getHistoryEvent(index, {from: this.account});
        })
        .then(value => {
          let event = new HistoryEvent(value[0], this.toDateTime(value[1]), value[2], value[3]);
          console.log(value);
          resolve(event);
        })
        .catch(e => {
          console.log(e);
          this.setStatus('Error getting max index; see log.');
          reject(e);
        });
    });
  }

  addHistoryEvent = () => {
    this.Herodot
      .deployed()
      .then(instance => {
        return instance.addEvent(this.media, this.title, this.description, {from: this.account});
      })
      .then(value => {
        console.log(value);
      })
      .catch(e => {
        console.log(e);
        this.setStatus('Error getting max index; see log.');
      });
  };

  toDateTime = (secs) => {
    let t = new Date(1970, 0, 1); // Epoch
    t.setSeconds(secs);
    return t;
  }

  onReady = () => {
    // Bootstrap the MetaCoin abstraction for Use.
    this.MetaCoin.setProvider(this.web3.currentProvider);
    this.Herodot.setProvider(this.web3.currentProvider);
    // Get the initial account balance so it can be displayed.
    this.web3.eth.getAccounts((err, accs) => {
      if (err != null) {
        alert('There was an error fetching your accounts.');
        return;
      }

      if (accs.length === 0) {
        alert(
          'Couldn\'t get any accounts! Make sure your Ethereum client is configured correctly.'
        );
        return;
      }
      this.accounts = accs;
      this.account = this.accounts[0];
      console.log(this.account);

      // This is run from window:load and ZoneJS is not aware of it we
      // need to use _ngZone.run() so that the UI updates on promise resolution
      this._ngZone.run(() =>
        this.refreshBalance()
      );
    });
  };

  refreshBalance = () => {
    let meta;
    this.MetaCoin
      .deployed()
      .then(instance => {
        meta = instance;
        return meta.getBalance.call(this.account, {
          from: this.account
        });
      })
      .then(value => {
        this.balance = value;
      })
      .catch(e => {
        console.log(e);
        this.setStatus('Error getting balance; see log.');
      });
  };

  setStatus = message => {
    this.status = message;
  };
};
