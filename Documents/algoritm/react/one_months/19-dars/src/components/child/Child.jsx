import React from 'react';
import GrandChild from '../grandchild/GrandChild';

const Child = ({child}) => {
  return (
    <div>
     <GrandChild gchild={child}/> 
    </div>
  );
}

export default Child;
