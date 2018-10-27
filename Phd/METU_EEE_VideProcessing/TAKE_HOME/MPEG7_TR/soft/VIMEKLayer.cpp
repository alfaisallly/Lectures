// VIMEKLayer.cpp: implementation of the CVIMEK class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "VIMEK.h"
//#include "VIMEKDlg.h"
#include "VIMEKLayer.h"


#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//CVIMEKDlg m_dlgVIMEK;

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CVIMEK::CVIMEK()
{
	
}

CVIMEK::~CVIMEK()
{
	
}
void CVIMEK::SetFrame(CString filename, int frameNo)
{
	CImge &frame = (frameNo == 1) ? m_frame1 : m_frame2;
	frame.FromFile(filename);
}

void CVIMEK::ShowFrame(CWnd* wnd, int frameNo)
{
	CImge &frame = (frameNo == 1) ? m_frame1 : m_frame2;
	CRect r;
	wnd->GetClientRect(r);
	frame.ImShow(wnd->m_hWnd, Rect(0,  0,r.Width(), r.Height())); 
}

bool CVIMEK::TrackFeatures(int wind)
{
	// Extract the features using the gradient matrix
	bool motion = false; // 0 --> no motion ; 1 --> motion
	
	double variance;
	double mean;
	
	double motion_threshold = 10;
	
	int h = m_frame1.height;
	int w = m_frame1.width;
	

	
	CImge Diff(h,w);
	
	Diff = m_frame1 - m_frame2;
	
	Diff = Diff.Abs();
	
	// analyze the variance of the difference images in order to decide on the motion/no-motion cases
	
	variance = Diff.Variance();
	mean = Diff.Mean();
	
	if ((mean+0.1*variance) > motion_threshold)
	{
		motion = true;
		//m_dlgVIMEK.SetStaticMotion(motion);
		
	}
	else 
	{
		motion = false;
		//m_dlgVIMEK.SetStaticMotion(motion);
		
	}
	
	if(motion)
	{
		
		CImge I_x(h-2,w-2);
		CImge I_y(h-2,w-2);
		
		I_x = m_frame1.Diff_x();
		I_y = m_frame1.Diff_y();
		
		m_frame1.Feature_inv(I_x, I_y, wind);
		
		// Track the features using Kanade Lucas Fature Tracker
		
		CImge Grad_curr(2,2);
		
		CImge Vx(h,w);
		CImge Vy(h,w);
		
		Vx.SetAllPxlsTo(0);
		Vy.SetAllPxlsTo(0);
		
		CImge v(2,1);
		v.SetAllPxlsTo(0);
		
		CImge b(2,1);
		b.SetAllPxlsTo(0);
		
		CImge n(2,1);
		n.SetAllPxlsTo(0);
		
		CImge d(2,1);
		d.SetAllPxlsTo(0);
		
		CImge g(2,1);
		g.SetAllPxlsTo(0);
		
		CImge g_v(2,1);
		g_v.SetAllPxlsTo(0);
		CImge g_v_tam(2,1);
		CImge g_v_dec(2,1);
		g_v_dec.SetAllPxlsTo(0);
		g_v_tam.SetAllPxlsTo(0);
		
		CImge temp_diff(h,w);
		temp_diff.SetAllPxlsTo(0);
		
		int K=5;
		int gt=0;
		int i;
		int j;
		int n1=0;
		int n2=0;
		int i_0;
		int j_0;
		int i_eski=-5;
		int j_eski=-5;
		int ft=0;
		int ind=0;
		int win_x=0;
		int win_y=0;
		int g_det=0;
		int h_l=0;
		int w_l=0;
		int pyr_level=3;
		int window=5;
		int level=0;
		
		//////////////////////////////////////////////////////////
		
		CImge* Pyr_I=new CImge[pyr_level];
		CImge* Pyr_I_x=new CImge[pyr_level];
		CImge* Pyr_I_y=new CImge[pyr_level];
		CImge* Pyr_J=new CImge[pyr_level];
		CImge* Pyr_J_temp=new CImge[pyr_level];
		
		Pyr_I[0]=m_frame1;
		Pyr_J[0]=m_frame2;
		Pyr_J_temp[0]=m_frame2;
		
		for(i=1;i<pyr_level;i++)
		{
			Pyr_I[i]=Pyr_I[i-1].PyramidSeed();
			Pyr_J[i]=Pyr_J[i-1].PyramidSeed();
		}
		
		for (i=pyr_level-1; i>=1;i--)
		{
			//Construct the x and y derivatives of the image for each hierarchical level
			Pyr_I_x[i]=Pyr_I[i].Diff_x();
			Pyr_I_y[i]=Pyr_I[i].Diff_y();
		}
		
		// First level derivative is equal to the original difference image
		Pyr_I_x[0]=I_x ;
		Pyr_I_y[0]=I_y;
		
		////////////////////////////////////////////////////////////////////////
		
		//m_frame1.Feature_no=0.5*m_frame1.Feature_no;
		
		// Iterative Optical Flow Estimation using Kanade Lucas Tracker Algorithm
		while (ft<m_frame1.Feature_no)
		{
			b.SetAllPxlsTo(0);
			v.SetAllPxlsTo(0);
			n.SetAllPxlsTo(0);
			d.SetAllPxlsTo(0);
			g_v.SetAllPxlsTo(0);
			g.SetAllPxlsTo(0);
			level=pyr_level;
			
			//i_0=m_frame1.Feature_List.GetAt(ind);
			//j_0=m_frame1.Feature_List.GetAt(ind+1);
			//ind=ind+2;
			
			i_0 = m_frame1.mFeature[ft].x;
			j_0 = m_frame1.mFeature[ft].y;
			
			if (i_0>=window+1 && i_0<=h-window-1 && j_0>=window+1 && j_0<=w-window-1)
			{
				///////////////Outer iteration loop (Pyramidal tracking)/////////////
				while(level>0)
				{
					b.SetAllPxlsTo(0);
					v.SetAllPxlsTo(0);
					n.SetAllPxlsTo(0);
					d.SetAllPxlsTo(0);
					
					i=i_0/(pow(2,level-1));
					j=j_0/(pow(2,level-1));
					h_l=h/(pow(2,level-1));
					w_l=w/(pow(2,level-1));								
					
					if (i>=window+window && i<=h_l-window-window && j>=window+window && j<=w_l-window-window)
					{					
						//Calculate the inverse G matrix for this feature point
						Grad_curr.SetAllPxlsTo(0);
						
						for (win_x=i-window;win_x<=i+window;win_x++)
						{
							for(win_y=j-window;win_y<=j+window;win_y++)
							{
								Grad_curr(0,0)+=pow(Pyr_I_x[level-1](win_x,win_y),2);
								Grad_curr(0,1)+=Pyr_I_x[level-1](win_x,win_y)*Pyr_I_y[level-1](win_x,win_y);
								Grad_curr(1,1)+=pow(Pyr_I_y[level-1](win_x,win_y),2);
							}
						}
						
						Grad_curr(1,0)=Grad_curr(0,1);
						
						g_det=Grad_curr(0,0)*Grad_curr(1,1)-Grad_curr(1,0)*Grad_curr(0,1);
						
						if (abs(g_det)>0.1)
						{					
							Grad_curr=Grad_curr.Inverse();
							
							///////////////Inner iteration loop (Iterative KLT)/////////////
							for (int k=0;k<K;k++)
							{				
								b.SetAllPxlsTo(0);
								n.SetAllPxlsTo(0);
								
								g_v=g+v;
								
								g_v_tam(0,0)=floor(g_v(0,0));
								g_v_dec(0,0)=g_v(0,0)-g_v_tam(0,0);
								
								g_v_tam(1,0)=floor(g_v(1,0));
								g_v_dec(1,0)=g_v(1,0)-g_v_tam(1,0);
								
								if ( abs(g_v(0,0))>=window || abs(g_v(1,0))>=window )
								{
									g_v.SetAllPxlsTo(window-2);
									break;
								}
								
								for (win_x=i-window;win_x<=i+window;win_x++)
								{
									for(win_y=j-window;win_y<=j+window;win_y++)
									{							
										temp_diff(win_x,win_y)=Pyr_I[level-1](win_x,win_y)-((1-g_v_dec(0,0))*(1-g_v_dec(1,0))*\
											Pyr_J[level-1](win_x+g_v_tam(0,0),win_y+g_v_tam(1,0))+\
											(1-g_v_dec(0,0))*g_v_dec(1,0)*Pyr_J[level-1](win_x+g_v_tam(0,0),win_y+1+g_v_tam(1,0))+\
											(1-g_v_dec(1,0))*g_v_dec(0,0)*Pyr_J[level-1](win_x+1+g_v_tam(0,0),win_y+g_v_tam(1,0))+\
											g_v_dec(0,0)*g_v_dec(1,0)*Pyr_J[level-1](win_x+1+g_v_tam(0,0),win_y+1+g_v_tam(1,0)));
									}
								}	
								
								for (win_x=i-window;win_x<=i+window;win_x++)
								{
									for(win_y=j-window;win_y<=j+window;win_y++)
									{
										b(0,0)+=temp_diff(win_x,win_y)*Pyr_I_x[level-1](win_x,win_y);
										b(1,0)+=temp_diff(win_x,win_y)*Pyr_I_y[level-1](win_x,win_y);
									}
								}
								
								n(0,0)=Grad_curr(0,0)*b(0,0)+Grad_curr(1,0)*b(1,0);
								n(1,0)=Grad_curr(0,1)*b(0,0)+Grad_curr(1,1)*b(1,0);
								
								
								if ( abs(n(0,0))>=4 || abs(n(1,0))>=4 )
								{
									v.SetAllPxlsTo(0);
									n.SetAllPxlsTo(0);
									break;
								}
								
								v=v+n;
								
								if ( abs(v(0,0))>=4 || abs(v(1,0))>=4 )
									break;
								
								if (v(0,0)<=0.03 && v(1,0)<=0.03 && v(0,0)>=-0.03 && v(1,0)>=-0.03)
									break;
							}//end of inner iteration loop
							
							d=v;
							
							g=(g+d);
							if (level-1!=0)
								g=g*2;
							
							level--;
						}//end of if (g_det>0.5)
						else
						{
							level--;
						}
					}//end of if (i<...)
					else
						level--;
					
				}//end of while (level>0)				
				
				///////////// The result //////////				
				Vx(i_0,j_0)=g(0,0);
				Vy(i_0,j_0)=g(1,0);
				
				m_frame1.mFeature[ft].vx = g(0,0);
				m_frame1.mFeature[ft].vy = g(1,0);
			
				///////////////////////////////////		
				
			}//end of if (i>=5 && i<=h-5 && j>=5 && j<=w-5) 
			ft++;
		}//end of while (ft<Feature_no)
		
		/********************************************************/
		/**************writing to a text file********************/
		/********************************************************/
		
		FILE *dosya1;
		dosya1=fopen("D:\\KLT_V_x.txt","wt");
		
		for (n1=10;n1<h-10;n1++)
		{
			for (n2=10;n2<w-10;n2++)
			{
				fprintf(dosya1,"%f\t",Vx(n1,n2));	
			}	
		}
		fclose(dosya1);
		
		FILE *dosya2;
		dosya2=fopen("D:\\KLT_V_y.txt","wt");
		
		for (n1=10;n1<h-10;n1++)
		{
			for (n2=10;n2<w-10;n2++)
			{
				fprintf(dosya2,"%f\t",Vy(n1,n2));	
			}	
		}
		fclose(dosya2);
	}

	return motion;
}

void CVIMEK::DisplayFeatures(CWnd* wnd)
{
	CRect	r;
	CSize	s;
	CDC* pDC = wnd->GetDC();
	CBrush	rb(0xff);

	wnd->GetWindowRect(r);
	s.cx = m_frame1.height;
	s.cy = m_frame2.width;
	pDC->SelectObject(&rb);
	pDC->SetBkMode(TRANSPARENT);
	pDC->SetTextColor(0xff);

	for (int i = 0; i < m_frame1.Feature_no; i ++)
	{
		CPoint fp, dp;

		fp.x = m_frame1.mFeature[i].x;
		fp.y = m_frame1.mFeature[i].y;
		dp = NormalizePointLocations(fp, s, r);

		pDC->TextOut(dp.y, dp.x, "*");
	//	dp.x = (int) (dp.x + m_frame1.mFeature[i].vx);
	//	dp.y = (int) (dp.y + m_frame1.mFeature[i].vy);
	//	pDC->LineTo(dp.y, dp.x);
	}

	pDC->SelectStockObject(BLACK_BRUSH);
	rb.DeleteObject();
	wnd->ReleaseDC(pDC);
}


CPoint CVIMEK::NormalizePointLocations(CPoint p, CSize s, const CRect &r)
{
	CPoint normalPt;

	normalPt.x = (p.x)*r.Height()/s.cx - 4;
	normalPt.y = (p.y)*r.Width()/s.cy - 5;
	return normalPt;
}	

void CVIMEK:: SetRGBFrame (CString fileName, int frameNo)
{
	CImge &frame_B = (frameNo == 1) ? m_frame1_B : m_frame2_B;
	CImge &frame_G = (frameNo == 1) ? m_frame1_G : m_frame2_G;
	CImge &frame_R = (frameNo == 1) ? m_frame1_R : m_frame2_R;
	
	m_frame1_B.GetColorFromFromFile(fileName, 'B');
	m_frame1_G.GetColorFromFromFile(fileName, 'G');
	m_frame1_R.GetColorFromFromFile(fileName, 'R');
	m_frame2_B.GetColorFromFromFile(fileName, 'B');
	m_frame2_G.GetColorFromFromFile(fileName, 'G');
	m_frame2_R.GetColorFromFromFile(fileName, 'R');
}

void CVIMEK::RGBImsToBuff(unsigned char* & buf, int frameNo) /* buffer'i CGdiplusWrapper nesnesine y�klemek
													istedigimizi varsayarak... (stride=4k) */
{
	CImge &frame_B = (frameNo == 1) ? m_frame1_B : m_frame2_B;
	CImge &frame_G = (frameNo == 1) ? m_frame1_G : m_frame2_G;
	CImge &frame_R = (frameNo == 1) ? m_frame1_R : m_frame2_R;
	int padding=frame_R.width%4;//4-((width*3)%4);
	int i,j,size;
	size=frame_R.height*(3*frame_R.width+padding);
	buf=new unsigned char[size];
	int b_index,h_index;

	for (i=frame_R.height-1;i>=0;i--)
	{
		h_index=i*(3*frame_R.width+padding);
		for (j=frame_R.width-1;j>=0;j--)
		{
			b_index=h_index+j*3;
			buf[b_index+2]=frame_R.Image[i][j];
			buf[b_index+1]=frame_G.Image[i][j];
			buf[b_index]=frame_B.Image[i][j];
		}
	}
}
void CVIMEK::ShowRGBFrame(CWnd* wnd, int frameNo)
{
	BYTE* buf;
	CImge &frame = (frameNo == 1) ? m_frame1 : m_frame2;
	CRect r;
	wnd->GetClientRect(r);
	RGBImsToBuff(buf, frameNo);
	CGdiplusWrapper wrap;
	wrap.LoadPixelData(buf, Point(frame.width, frame.height));
	wrap.Display(wnd->m_hWnd, Rect(0,  0,r.Width(), r.Height()));
	delete [] buf;
}

