// $Id: function_node.h,v 1.1 2017/03/23 17:59:34 ist181045 Exp $ -*- c++ -*-
#ifndef __XPL_FUNCTIONNODE_H__
#define __XPL_FUNCTIONNODE_H__

#include <cdk/ast/basic_node.h>
#include <cdk/basic_type.h>

namespace xpl {

  /**
   * Class for describing program nodes.
   */
  class function_node: public cdk::basic_node {
    basic_type *_type;
    cdk::sequence_node *_declarations;
    cdk::sequence_node *_statements;

  public:
    inline function_node(int lineno, cdk::sequence_node *declarations
        cdk::sequence_node *statements) :
      cdk::basic_node(lineno), _declarations(declarations), _statements(statements) {
    }

  public:
    inline basic_type *type() {
      return _type;
    }
    
    inline cdk::sequence_node *declarations() {
      return _declarations;
    }

    inline cdk::sequence_node *statements() {
      return _statements;
    }

    void accept(basic_ast_visitor *sp, int level) {
      sp->do_function_node(this, level);
    }

  };

} // xpl

#endif