import React from 'react';
import GrandChild from '../grandchild/GrandChild';

const Child = ({child}) => {
  return (
    <div>
        <h1>alo</h1>
     <GrandChild gchild={child}/> 
    </div>
  );
}

export default Child;
