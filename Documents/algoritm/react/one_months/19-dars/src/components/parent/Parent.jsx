import React from 'react';
import Child from '../child/Child';

const Parent = ({user}) => {
  return (
    <div>
      <Child child={user}/>
    </div>
  );
}

export default Parent;
