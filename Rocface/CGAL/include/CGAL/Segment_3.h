// ======================================================================
//
// Copyright (c) 1999 The CGAL Consortium

// This software and related documentation is part of the Computational
// Geometry Algorithms Library (CGAL).
// This software and documentation is provided "as-is" and without warranty
// of any kind. In no event shall the CGAL Consortium be liable for any
// damage of any kind. 
//
// Every use of CGAL requires a license. 
//
// Academic research and teaching license
// - For academic research and teaching purposes, permission to use and copy
//   the software and its documentation is hereby granted free of charge,
//   provided that it is not a component of a commercial product, and this
//   notice appears in all copies of the software and related documentation. 
//
// Commercial licenses
// - A commercial license is available through Algorithmic Solutions, who also
//   markets LEDA (http://www.algorithmic-solutions.de). 
// - Commercial users may apply for an evaluation license by writing to
//   Algorithmic Solutions (contact@algorithmic-solutions.com). 
//
// The CGAL Consortium consists of Utrecht University (The Netherlands),
// ETH Zurich (Switzerland), Free University of Berlin (Germany),
// INRIA Sophia-Antipolis (France), Martin-Luther-University Halle-Wittenberg
// (Germany), Max-Planck-Institute Saarbrucken (Germany), RISC Linz (Austria),
// and Tel-Aviv University (Israel).
//
// ----------------------------------------------------------------------
// 
// release       : CGAL-2.2
// release_date  : 2000, September 30
// 
// source        : Segment_3.fw
// file          : include/CGAL/Segment_3.h
// package       : _3 (3.7)
// revision      : 3.7
// revision_date : 16 Aug 2000 
// author(s)     : Andreas Fabri
//                 Stefan Schirra
//
// coordinator   : MPI, Saarbruecken  (<Stefan.Schirra>)
// email         : contact@cgal.org
// www           : http://www.cgal.org
//
// ======================================================================
 

#ifndef CGAL_SEGMENT_3_H
#define CGAL_SEGMENT_3_H

#ifndef CGAL_REP_CLASS_DEFINED
#error  no representation class defined
#endif  // CGAL_REP_CLASS_DEFINED

#ifdef CGAL_HOMOGENEOUS_H
#ifndef CGAL_SEGMENTH3_H
#include <CGAL/SegmentH3.h>
#endif // CGAL_SEGMENTH3_H
#endif // CGAL_HOMOGENEOUS_H

#ifdef CGAL_CARTESIAN_H
#ifndef CGAL_SEGMENTC3_H
#include <CGAL/Cartesian/Segment_3.h>
#endif // CGAL_SEGMENTC3_H
#endif // CGAL_CARTESIAN_H

#ifdef CGAL_SIMPLE_CARTESIAN_H
#include <CGAL/SimpleCartesian/SegmentS3.h>
#endif // CGAL_SIMPLE_CARTESIAN_H


#ifndef CGAL_LINE_3_H
#include <CGAL/Line_3.h>
#endif // CGAL_LINE_3_H

CGAL_BEGIN_NAMESPACE

template <class R_>
class Segment_3 : public R_::Segment_3_base
{
public:
  typedef          R_                       R;
  typedef typename R::RT                    RT;
  typedef typename R::FT                    FT;
  typedef typename R::Segment_3_base  RSegment_3;

  Segment_3() : RSegment_3()
  {}
  Segment_3(const CGAL::Segment_3<R>& s) : RSegment_3(s)
  {}
  Segment_3(const CGAL::Point_3<R>& sp, const CGAL::Point_3<R>& ep)
    : RSegment_3(sp,ep)
  {}
  Segment_3(const RSegment_3&  s) : RSegment_3(s)
  {}

  bool                 has_on(const CGAL::Point_3<R>& p) const
  { return RSegment_3::has_on(p); }
  bool                 operator==(const CGAL::Segment_3<R>& s) const
  { return RSegment_3::operator==(s); }
  bool                 operator!=(const CGAL::Segment_3<R>& s) const
  { return !(*this == s); }
  CGAL::Point_3<R>     start() const
  { return RSegment_3::start(); }
  CGAL::Point_3<R>     end() const
  { return RSegment_3::end(); }
  CGAL::Point_3<R>     source() const
  { return RSegment_3::source(); }
  CGAL::Point_3<R>     target() const
  { return RSegment_3::target(); }
  CGAL::Point_3<R>     min() const
  { return RSegment_3::min(); }
  CGAL::Point_3<R>     max() const
  { return RSegment_3::max(); }
  CGAL::Point_3<R>     vertex(int i) const
  { return RSegment_3::vertex(i); }
  CGAL::Point_3<R>     operator[](int i) const
  { return vertex(i); }
  FT                   squared_length() const
  { return RSegment_3::squared_length(); }
  CGAL::Direction_3<R> direction() const
  { return RSegment_3::direction(); }
  CGAL::Segment_3<R>  opposite() const
  { return CGAL::Segment_3<R>(target(),source()); }
  CGAL::Segment_3<R>  transform(const CGAL::Aff_transformation_3<R>& t) const
  { return RSegment_3::transform(t); }
  CGAL::Line_3<R>     supporting_line() const
  { return RSegment_3::supporting_line(); }
  bool                is_degenerate() const
  { return RSegment_3::is_degenerate(); }
  Bbox_3         bbox() const
  { return source().bbox() + target().bbox(); }
};


#ifndef NO_OSTREAM_INSERT_SEGMENT_3
template < class R>
std::ostream&
operator<<(std::ostream& os, const Segment_3<R>& s)
{
  typedef typename  R::Segment_3_base  RSegment_3;
  return os << (const RSegment_3& )s;
}
#endif // NO_OSTREAM_INSERT_SEGMENT_3

#ifndef NO_ISTREAM_EXTRACT_SEGMENT_3
template < class R>
std::istream&
operator>>(std::istream& is, Segment_3<R>& s)
{
  typedef typename  R::Segment_3_base  RSegment_3;
  return is >> (RSegment_3& )s;
}
#endif // NO_ISTREAM_EXTRACT_SEGMENT_3


CGAL_END_NAMESPACE


#endif // CGAL_SEGMENT_3_H
