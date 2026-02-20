import React from 'react';
import Parent from './components/parent/Parent';

const App = () => {

  const user = `toshmat`;

  return (
    <div>
      <Parent user={user}/>
    </div>
  );
}

export default App;
