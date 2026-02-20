import React from 'react';
import Parent from './components/parent/Parent';
import { UserContext } from './components/context/UserContext';
import GrandChild from './components/grandchild/GrandChild';

const App = () => {

  const user = `toshmat`;

  return (
    <div>
      <UserContext.Provider value={user}>
          <GrandChild/>
      </UserContext.Provider>
    </div>
  );
}

export default App;
