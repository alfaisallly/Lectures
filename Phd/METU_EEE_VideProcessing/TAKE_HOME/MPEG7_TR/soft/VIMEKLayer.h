// VIMEKLayer.h: interface for the CVIMEK class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_VIMEKLAYER_H__E4FEF210_0578_4709_A1DC_CFDC39CAD1C8__INCLUDED_)
#define AFX_VIMEKLAYER_H__E4FEF210_0578_4709_A1DC_CFDC39CAD1C8__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
#include "imge.h"




class CVIMEK  
{
public:
	void	SetFrame(CString fileName, int frameNo);
	void	ShowFrame(CWnd* wnd, int frameNo);
	bool	TrackFeatures(int window);
	void	DisplayFeatures(CWnd* wnd);
	void	RANSAC();
	double Rx,Ry,Rz,Tx,Ty,Tz;
	CImge m_frame1_R,m_frame1_B,m_frame1_G, m_frame2_R,m_frame2_B,m_frame2_G;
	void SetRGBFrame(CString fileName, int frameNo);
	void ShowRGBFrame(CWnd* wnd, int frameNo);
	void RGBImsToBuff(unsigned char* & buf, int frameNo);

	CVIMEK();
	virtual ~CVIMEK();
	
private:
	CImge	m_frame1;
	CImge	m_frame2;
	CImge Vx;
	CImge Vy;


	
protected:
	CPoint NormalizePointLocations(CPoint p, CSize s, const CRect &r);
};

#endif // !defined(AFX_VIMEKLAYER_H__E4FEF210_0578_4709_A1DC_CFDC39CAD1C8__INCLUDED_)
